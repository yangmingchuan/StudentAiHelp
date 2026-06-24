"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const { createServer } = require("../index");
const { MemoryRepository } = require("../lib/repositories/memory_repository");

function listen(server) {
  return new Promise((resolve) => {
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      resolve(`http://127.0.0.1:${address.port}`);
    });
  });
}

async function request(baseUrl, path, options = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: {
      Accept: "application/json",
      ...(options.headers || {}),
    },
  });
  const body = await response.json();
  return { response, body };
}

test("bootstrap creates default MVP profile and returns today data", async () => {
  const server = createServer({
    repository: new MemoryRepository(),
    env: { NODE_ENV: "test", INTERNAL_API_SECRET: "secret" },
  });
  const baseUrl = await listen(server);

  try {
    const { response, body } = await request(baseUrl, "/api/bootstrap", {
      headers: { Authorization: "Bearer test:parent-1:13800138000" },
    });

    assert.equal(response.status, 200);
    assert.equal(body.data.parent.username, "13800138000");
    assert.equal(body.data.parent.phoneMasked, "138****8000");
    assert.equal(body.data.child.nickname, "小勇士");
    assert.equal(body.data.child.needsProfileSetup, true);
    assert.equal(body.data.assets.availableStars, 0);
    assert.equal(body.data.assets.hearts.remaining, 10);
    assert.equal(body.data.todayTasks.length, 3);
    assert.deepEqual(
      body.data.todayTasks.map((task) => task.name),
      ["自己刷牙", "整理床铺", "阅读绘本"],
    );
  } finally {
    server.close();
  }
});

test("internal default profile endpoint is idempotent", async () => {
  const server = createServer({
    repository: new MemoryRepository(),
    env: { INTERNAL_API_SECRET: "secret" },
  });
  const baseUrl = await listen(server);

  try {
    const payload = JSON.stringify({
      authSubject: "parent-1",
      username: "13800138000",
    });
    const first = await request(baseUrl, "/internal/parents/default-profile", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Internal-Secret": "secret",
      },
      body: payload,
    });
    const second = await request(baseUrl, "/internal/parents/default-profile", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Internal-Secret": "secret",
      },
      body: payload,
    });

    assert.equal(first.response.status, 201);
    assert.equal(second.response.status, 200);
    assert.equal(first.body.data.childId, second.body.data.childId);
    assert.equal(second.body.data.createdChild, false);
  } finally {
    server.close();
  }
});

test("records task status idempotently and settles stars", async () => {
  const server = createServer({
    repository: new MemoryRepository(),
    env: { NODE_ENV: "test", INTERNAL_API_SECRET: "secret" },
  });
  const baseUrl = await listen(server);

  try {
    const bootstrap = await request(baseUrl, "/api/bootstrap", {
      headers: { Authorization: "Bearer test:parent-1:13800138000" },
    });
    const childId = bootstrap.body.data.child.id;
    const taskId = bootstrap.body.data.todayTasks[0].id;

    const first = await request(baseUrl, "/api/tasks/record", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer test:parent-1:13800138000",
      },
      body: JSON.stringify({
        operationId: "op-1",
        childId,
        taskId,
        status: "done",
      }),
    });
    const second = await request(baseUrl, "/api/tasks/record", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer test:parent-1:13800138000",
      },
      body: JSON.stringify({
        operationId: "op-1",
        childId,
        taskId,
        status: "done",
      }),
    });

    assert.equal(first.response.status, 200);
    assert.equal(second.response.status, 200);
    assert.equal(first.body.data.snapshot.assets.availableStars, 1);
    assert.equal(second.body.data.snapshot.assets.availableStars, 1);
    assert.equal(first.body.data.snapshot.badges.earnedCount, 1);
  } finally {
    server.close();
  }
});

test("manages tasks idempotently", async () => {
  const server = createServer({
    repository: new MemoryRepository(),
    env: { NODE_ENV: "test", INTERNAL_API_SECRET: "secret" },
  });
  const baseUrl = await listen(server);

  try {
    await request(baseUrl, "/api/bootstrap", {
      headers: { Authorization: "Bearer test:parent-1:13800138000" },
    });
    const created = await request(baseUrl, "/api/tasks/manage", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer test:parent-1:13800138000",
      },
      body: JSON.stringify({
        operationId: "task-op-1",
        action: "create",
        taskId: 999,
        name: "喝牛奶",
        sortOrder: 40,
      }),
    });
    const repeated = await request(baseUrl, "/api/tasks/manage", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer test:parent-1:13800138000",
      },
      body: JSON.stringify({
        operationId: "task-op-1",
        action: "create",
        taskId: 999,
        name: "喝牛奶",
        sortOrder: 40,
      }),
    });

    assert.equal(created.response.status, 200);
    assert.equal(repeated.response.status, 200);
    assert.equal(
      created.body.data.snapshot.todayTasks.some((task) => task.name === "喝牛奶"),
      true,
    );
    assert.equal(
      repeated.body.data.snapshot.todayTasks.filter((task) => task.id === 999)
        .length,
      1,
    );
  } finally {
    server.close();
  }
});
