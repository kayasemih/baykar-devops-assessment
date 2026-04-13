import { MongoClient } from "mongodb";

const connectionString =
  process.env.ATLAS_URI || "mongodb://localhost:27017/sample_training";

let clientPromise;
let database;

async function connectClient() {
  const client = new MongoClient(connectionString);

  try {
    await client.connect();
    return client;
  } catch (error) {
    await client.close().catch(() => {});
    throw error;
  }
}

async function getClient() {
  if (!clientPromise) {
    // Reset the cached promise on connection failure so readiness checks can recover
    // once MongoDB becomes available.
    clientPromise = connectClient().catch((error) => {
      clientPromise = undefined;
      database = undefined;
      throw error;
    });
  }

  return clientPromise;
}

export async function getDb() {
  if (!database) {
    const client = await getClient();
    database = client.db("sample_training");
  }

  return database;
}

export async function pingDatabase() {
  const db = await getDb();
  await db.command({ ping: 1 });
}

export default getDb;
