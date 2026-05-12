"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");

const { runMinerTest } = require("./common/miner_command");
const { hashTests } = require("./vectors");

describe("proof-of-work hash vectors", () => {
  for (const definition of hashTests) {
    it(definition.name, { timeout: definition.timeoutMs || 5 * 60 * 1000 }, async (t) => {
      const result = await runMinerTest(definition);
      if (result.skipped) {
        t.skip(result.reason);
        return;
      }

      assert.equal(result.skipped, false);
    });
  }
});
