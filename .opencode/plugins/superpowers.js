// MySuperPowers OpenCode Plugin
// Merged from Superpowers + Matt Pocock Skills
export default {
  name: "mysuperpowers",
  hooks: {
    "session:start": async (context) => {
      // Injects bootstrap content at session start
      return {
        context: "MySuperPowers is loaded. Skills available for brainstorming, TDD, debugging, planning, domain language, and workflow management."
      };
    }
  }
};
