import app from "./app.mjs";

const PORT = Number(process.env.PORT || 5050);

// start the Express server
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
