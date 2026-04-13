import express from "express";
import getDb from "../db/conn.mjs";
import { ObjectId } from "mongodb";

const router = express.Router();

function getRecordId(id, res) {
  if (!ObjectId.isValid(id)) {
    res.status(400).json({ message: "Invalid record id" });
    return null;
  }

  return new ObjectId(id);
}

async function withCollection(res, handler) {
  try {
    const collection = (await getDb()).collection("records");
    return await handler(collection);
  } catch (error) {
    console.error("Record route failed", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

// This section will help you get a list of all the records.
router.get("/", async (req, res) => {
  return withCollection(res, async (collection) => {
    const results = await collection.find({}).toArray();
    return res.status(200).json(results);
  });
});

// This section will help you get a single record by id
router.get("/:id", async (req, res) => {
  const recordId = getRecordId(req.params.id, res);

  if (!recordId) {
    return;
  }

  return withCollection(res, async (collection) => {
    const result = await collection.findOne({ _id: recordId });

    if (!result) {
      return res.status(404).json({ message: "Not found" });
    }

    return res.status(200).json(result);
  });
});

// This section will help you create a new record.
router.post("/", async (req, res) => {
  const newDocument = {
    name: req.body.name,
    position: req.body.position,
    level: req.body.level,
  };

  return withCollection(res, async (collection) => {
    const result = await collection.insertOne(newDocument);
    return res.status(201).json(result);
  });
});

// This section will help you update a record by id.
router.patch("/:id", async (req, res) => {
  const recordId = getRecordId(req.params.id, res);

  if (!recordId) {
    return;
  }

  const updates = {
    $set: {
      name: req.body.name,
      position: req.body.position,
      level: req.body.level,
    },
  };

  return withCollection(res, async (collection) => {
    const result = await collection.updateOne({ _id: recordId }, updates);
    return res.status(200).json(result);
  });
});

// This section will help you delete a record
router.delete("/:id", async (req, res) => {
  const recordId = getRecordId(req.params.id, res);

  if (!recordId) {
    return;
  }

  return withCollection(res, async (collection) => {
    const result = await collection.deleteOne({ _id: recordId });
    return res.status(200).json(result);
  });
});

export default router;
