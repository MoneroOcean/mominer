// Copyright GNU GPLv3 (c) 2023-2025 MoneroOcean <support@moneroocean.stream>

#pragma once

#include <iostream>
#include <string>
#include <algorithm>
#include <iterator>
#include <thread>
#include <deque>
#include <map>
#include <mutex>
#include <chrono>
#include <condition_variable>
#include <nan.h>

typedef std::map<std::string, std::string> MessageValues;

struct Message {
  std::string name;
  MessageValues values;
  Message(std::string name, MessageValues values) : name(name), values(values) {}
};

template<typename T> class MessageQueue {
  std::mutex              m_mutex;
  std::condition_variable m_cond;
  std::deque<T>           m_buff;

  public:

  void write(T data) {
    while (true) {
      std::unique_lock<std::mutex> locker(m_mutex);
      m_buff.push_back(data);
      locker.unlock();
      m_cond.notify_all();
      return;
    }
  }

  T read() {
    while (true) {
      std::unique_lock<std::mutex> locker(m_mutex);
      m_cond.wait(locker, [this]() { return m_buff.size() > 0; });
      T back = m_buff.front();
      m_buff.pop_front();
      locker.unlock();
      m_cond.notify_all();
      return back;
    }
  }

  void readAll(std::deque<T>& target) {
    std::unique_lock<std::mutex> locker(m_mutex);
    std::copy(m_buff.begin(), m_buff.end(), std::back_inserter(target));
    m_buff.clear();
    locker.unlock();
  }
};

class AsyncWorker: public Nan::AsyncProgressQueueWorker<char> {
  Nan::Callback* const  m_progress;
  Nan::Callback* const  m_error_callback;
  MessageQueue<Message> m_toNode;

  void drainQueue() {
    Nan::HandleScope scope;
    auto ctx = v8::Isolate::GetCurrent()->GetCurrentContext();
    std::deque<Message> contents;
    m_toNode.readAll(contents);

    for (const Message& msg : contents) {
      v8::Local<v8::Object> values = Nan::New<v8::Object>();
      for (auto pi = msg.values.begin(); pi != msg.values.end(); ++ pi) {
        values->Set(
          ctx, Nan::New<v8::String>(pi->first.c_str()).ToLocalChecked(),
          Nan::New<v8::String>(pi->second.c_str()).ToLocalChecked()
        ).Check();
      }
      v8::Local<v8::Value> argv[] = {
        Nan::New<v8::String>(msg.name.c_str()).ToLocalChecked(),
        values
      };
      m_progress->Call(2, argv, async_resource);
    }
  }

  void HandleErrorCallback() {
    v8::Local<v8::Value> argv[] = {
      v8::Exception::Error(Nan::New<v8::String>(ErrorMessage()).ToLocalChecked())
    };
    m_error_callback->Call(1, argv, async_resource);
  }

  void HandleOKCallback() {
    drainQueue();
    callback->Call(0, nullptr, async_resource);
  }

  void HandleProgressCallback(const char*, size_t) {
    drainQueue();
  }

  protected:

  void sendToNode(
    const AsyncProgressQueueWorker<char>::ExecutionProgress& progress, const Message& msg
  ) {
    m_toNode.write(msg);
    progress.Send(reinterpret_cast<const char*>(&m_toNode), sizeof(m_toNode));
  }

  public:

  MessageQueue<Message> fromNode;

  AsyncWorker(
    Nan::Callback* const progress, Nan::Callback* const callback,
    Nan::Callback* const error_callback
  ) : Nan::AsyncProgressQueueWorker<char>(callback, "moner-core::AsyncWorker"),
      m_progress(progress), m_error_callback(error_callback) {}

  ~AsyncWorker() {
    delete m_progress;
    delete m_error_callback;
  }
};

AsyncWorker* create_worker(Nan::Callback*, Nan::Callback*, Nan::Callback*, v8::Local<v8::Object>&);

class AsyncWorkerWrapper: public Nan::ObjectWrap {
  AsyncWorker* const m_worker;

  explicit AsyncWorkerWrapper(AsyncWorker* const worker) : m_worker(worker) {}
  ~AsyncWorkerWrapper() {}

  static NAN_METHOD(New) {
    if (info.IsConstructCall()) {
      Nan::Callback* const data_callback     = new Nan::Callback(info[0].As<v8::Function>());
      Nan::Callback* const complete_callback = new Nan::Callback(info[1].As<v8::Function>());
      Nan::Callback* const error_callback    = new Nan::Callback(info[2].As<v8::Function>());
      v8::Local<v8::Object> options          = info[3].As<v8::Object>();

      AsyncWorkerWrapper* const obj = new AsyncWorkerWrapper(
        create_worker(data_callback, complete_callback, error_callback, options)
      );

      obj->Wrap(info.This());
      info.GetReturnValue().Set(info.This());

      // start the worker
      AsyncQueueWorker(obj->m_worker);

    } else {
      const int argc = 3;
      v8::Local<v8::Value> argv[argc] = { info[0], info[1], info[2] };
      v8::Local<v8::Function> cons   = Nan::New(constructor());
      v8::Local<v8::Object> instance = Nan::NewInstance(cons, argc, argv).ToLocalChecked();
      info.GetReturnValue().Set(instance);
    }
  }

  static NAN_METHOD(sendToCpp) {
    auto ctx = v8::Isolate::GetCurrent()->GetCurrentContext();
    const auto& name = Nan::Utf8String(info[0]->ToString(ctx).ToLocalChecked());
    const v8::Local<v8::Object> obj = info[1].As<v8::Object>();
    MessageValues values;
    const v8::Local<v8::Array> property_names = obj->GetOwnPropertyNames(ctx).ToLocalChecked();
    for (unsigned i = 0; i < property_names->Length(); ++i) {
      const v8::Local<v8::Value> key = property_names->Get(ctx, i).ToLocalChecked();
      const auto& key2  = Nan::Utf8String(key->ToString(ctx).ToLocalChecked());
      const auto& value = Nan::Utf8String(obj->Get(ctx, key).ToLocalChecked());
      values[*key2] = *value;
    }
    Nan::ObjectWrap::Unwrap<AsyncWorkerWrapper>(info.Holder())->
      m_worker->fromNode.write(Message(*name, values));
  }

  static inline Nan::Persistent<v8::Function>& constructor() {
    static Nan::Persistent<v8::Function> my_constructor;
    return my_constructor;
  }

  public:

  static NAN_MODULE_INIT(Init) {
    v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
    tpl->SetClassName(Nan::New("AsyncWorker").ToLocalChecked());
    tpl->InstanceTemplate()->SetInternalFieldCount(2);

    SetPrototypeMethod(tpl, "sendToCpp", sendToCpp);

    constructor().Reset(Nan::GetFunction(tpl).ToLocalChecked());
    Nan::Set(target, Nan::New("AsyncWorker").ToLocalChecked(),
    Nan::GetFunction(tpl).ToLocalChecked());
  }
};
