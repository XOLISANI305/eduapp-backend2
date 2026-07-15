// Stub AI tutor endpoint — replace with real Anthropic/OpenAI integration later
export const askTutor = async (req, res) => {
  try {
    const { question } = req.body;

    if (!question) {
      return res.status(400).json({ message: "A question is required" });
    }

    // TODO: Replace with real AI provider call once API key is set up
    return res.json({
      success: true,
      answer: "AI Tutor is coming soon! This feature is still being set up.",
      question
    });

  } catch (err) {
    console.error("Error in askTutor:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};