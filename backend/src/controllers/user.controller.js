import userService from "../services/user.service.js";

export const getUserProfile = async (req, res) => {
    try {
        const userToken = req.user;
        const userId = userToken ? userToken.uid : null;

        if (!userId) {
            console.log("❌ No userId in token");
            return res.status(401).json({ error: "Unauthorized" });
        }

        console.log("👤 Fetching profile for userId:", userId);

        // Use getOrCreateUser to automatically create user if not exists
        const userData = await userService.getOrCreateUser({
            uid: userId,
            email: userToken.email,
            name: userToken.name || userToken.email?.split('@')[0] || "Küçük Masalcı"
        });

        console.log("👤 User data received:", userData);

        res.json({
            success: true,
            user: {
                uid: userId,
                email: userToken.email,
                displayName: userData.displayName || userToken.name || "Küçük Masalcı",
                totalStoriesCreated: userData.totalStoriesCreated || 0,
                badges: userData.badges || [],
                lastStoryDate: userData.lastStoryGeneratedAt
            }
        });

    } catch (error) {
        console.error("Get Profile Error:", error);
        res.status(500).json({ error: error.message });
    }
};
