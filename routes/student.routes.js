import express from "express";

const router = express.Router();


router.get("/stats", (req, res) => {
  res.json({
    message: "Student stats working ✅",
    totalCourses: 5,
    completed: 2,
    progress: 40,
  });
});

export default router;