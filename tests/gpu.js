"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");

const { runMinerTest } = require("./common/miner_command");
const { hashTests } = require("./vectors");

describe("GPU proof-of-work hash vectors", () => {
  for (const definition of hashTests.filter((entry) => entry.gpu)) {
    it(definition.name, { timeout: definition.timeoutMs || 10 * 60 * 1000 }, async (t) => {
      const result = await runMinerTest(definition);
      if (result.skipped) {
        t.skip(result.reason);
        return;
      }

      assert.equal(result.skipped, false);
    });
  }
});
