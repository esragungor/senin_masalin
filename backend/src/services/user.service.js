import { db } from "../config/firebase.js";

const PUZZLE_TOTAL_PIECES = 7; // Her puzzle 7 parçaya bölünmüştür

class UserService {
    // Kullanıcıyı getir veya oluştur
    async getOrCreateUser(userData) {
        const userRef = db.collection("users").doc(userData.uid);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            const newUser = {
                uid: userData.uid,
                email: userData.email || "",
                displayName: userData.name || "Masal Sever",
                photoUrl: "",
                jetonBalance: 0,
                createdAt: new Date(),
                storiesCreated: 0,
                totalStoriesRead: 0,
                // Haftalık ilerleme
                weeklyProgress: {
                    count: 0,
                    weekStartDate: this._getMondayOfCurrentWeek().toISOString()
                },
                // Puzzle
                puzzleProgress: {
                    currentPuzzleId: 1,
                    collectedPieces: 0,  // 0-7
                    pieceIndices: [],    // Hangi parçalar (rastgele)
                    lastPieceDate: null  // 'YYYY-MM-DD' formatı
                },
                badges: [],
                completedPuzzles: [],
                lastTaleAt: null        // 30 sn cooldown için
            };
            await userRef.set(newUser);
            return newUser;
        }
        return userDoc.data();
    }

    // Pazartesiyi hesapla (haftalık sıfırlama için)
    _getMondayOfCurrentWeek() {
        const now = new Date();
        const day = now.getDay(); // 0=Pazar, 1=Pazartesi
        const diff = (day === 0) ? -6 : 1 - day;
        const monday = new Date(now);
        monday.setDate(now.getDate() + diff);
        monday.setHours(0, 0, 0, 0);
        return monday;
    }

    // Get User Profile Data
    async getUserProfile(uid) {
        const userRef = db.collection("users").doc(uid);
        const userDoc = await userRef.get();
        if (!userDoc.exists) return null;
        return userDoc.data();
    }

    /**
     * Masal kitaplığa kaydedildiğinde ilerlemeyi güncelle.
     * Transaction kullanır — paralel yazma güvenlidir.
     */
    async updateProgressForStory(uid) {
        const userRef = db.collection("users").doc(uid);

        return await db.runTransaction(async (transaction) => {
            const userDoc = await transaction.get(userRef);
            if (!userDoc.exists) throw new Error("Kullanıcı bulunamadı");

            let user = { ...userDoc.data() };
            const now = new Date();
            const todayStr = now.toISOString().split('T')[0]; // YYYY-MM-DD

            // 1. Genel istatistik
            user.storiesCreated = (user.storiesCreated || 0) + 1;

            // 2. Haftalık rozet mantığı — Pazartesi bazlı takvim haftası
            const currentMonday = this._getMondayOfCurrentWeek();
            const weekStart = user.weeklyProgress?.weekStartDate
                ? new Date(user.weeklyProgress.weekStartDate)
                : currentMonday;

            if (weekStart.getTime() < currentMonday.getTime()) {
                // Yeni hafta → sıfırla
                user.weeklyProgress = {
                    count: 1,
                    weekStartDate: currentMonday.toISOString()
                };
            } else {
                user.weeklyProgress.count = (user.weeklyProgress.count || 0) + 1;
            }

            // Haftalık rozet kontrolü (7 masal = 1 rozet)
            let newBadges = [];
            if (user.weeklyProgress.count === 7) {
                const badgeId = `weekly_master_${currentMonday.toISOString().split('T')[0]}`;
                if (!(user.badges || []).includes(badgeId)) {
                    user.badges = [...(user.badges || []), badgeId];
                    newBadges.push({ id: badgeId, name: "Haftalık Masal Ustası 🌟" });
                    console.log(`User ${uid} earned weekly badge: ${badgeId}`);
                }
            }

            // 3. Puzzle mantığı — günde 1 parça, 00:00-23:59 penceresi
            const lastPieceDate = user.puzzleProgress?.lastPieceDate || null;
            let puzzleUpdate = { gainedPiece: false, completed: false, pieceIndex: null };

            if (lastPieceDate !== todayStr) {
                const currentPieces = user.puzzleProgress?.collectedPieces || 0;
                const existingIndices = user.puzzleProgress?.pieceIndices || [];

                // Rastgele kullanılmayan bir parça indeksi seç (1-7)
                const allIndices = [1, 2, 3, 4, 5, 6, 7];
                const available = allIndices.filter(i => !existingIndices.includes(i));
                const newPieceIndex = available.length > 0
                    ? available[Math.floor(Math.random() * available.length)]
                    : null;

                const newPieces = currentPieces + 1;
                const newIndices = newPieceIndex
                    ? [...existingIndices, newPieceIndex]
                    : existingIndices;

                user.puzzleProgress = {
                    ...user.puzzleProgress,
                    collectedPieces: newPieces,
                    pieceIndices: newIndices,
                    lastPieceDate: todayStr
                };

                puzzleUpdate.gainedPiece = true;
                puzzleUpdate.pieceIndex = newPieceIndex;

                // Puzzle tamamlandı mı? (7 parça)
                if (newPieces >= PUZZLE_TOTAL_PIECES) {
                    const currentPuzzleId = user.puzzleProgress.currentPuzzleId || 1;
                    user.completedPuzzles = [...(user.completedPuzzles || []), currentPuzzleId];

                    // Yeni puzzle'a geç, bugün parça aldı sayılsın
                    user.puzzleProgress = {
                        currentPuzzleId: currentPuzzleId + 1,
                        collectedPieces: 0,
                        pieceIndices: [],
                        lastPieceDate: todayStr
                    };
                    puzzleUpdate.completed = true;
                    console.log(`User ${uid} completed puzzle ${currentPuzzleId}!`);
                }
            }

            // 4. Cooldown güncelle
            user.lastTaleAt = now.toISOString();

            await transaction.update(userRef, user);
            return { user, newBadges, puzzleUpdate };
        });
    }

    /**
     * Jeton bakiyesini güncelle ve işlemi kaydet
     * @param {string} uid
     * @param {number} amount - pozitif=kazanç, negatif=harcama
     * @param {string} reason
     * @param {string|null} referenceId
     */
    async updateJetonBalance(uid, amount, reason, referenceId = null) {
        const userRef = db.collection("users").doc(uid);

        await db.runTransaction(async (transaction) => {
            const userDoc = await transaction.get(userRef);
            if (!userDoc.exists) throw new Error("Kullanıcı bulunamadı");

            const currentBalance = userDoc.data().jetonBalance || 0;
            const newBalance = currentBalance + amount;

            if (newBalance < 0) throw new Error("Yetersiz jeton bakiyesi");

            transaction.update(userRef, { jetonBalance: newBalance });
        });

        // Jeton işlem kaydı
        await db.collection("jeton_transactions").add({
            userId: uid,
            amount,
            reason,
            referenceId: referenceId || null,
            createdAt: new Date()
        });
    }
}

export default new UserService();
