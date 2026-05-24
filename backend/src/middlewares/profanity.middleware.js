import axios from "axios";

const GITHUB_LISTE_URL = "https://raw.githubusercontent.com/ooguz/turkce-kufur-karaliste/master/karaliste.txt";

let yasakliKelimeler = [];

// Backend başlarken listeyi bir kere çekip belleğe alırız
export const initProfanityFilter = async () => {
    try {
        const response = await axios.get(GITHUB_LISTE_URL);
        yasakliKelimeler = response.data
            .split("\n")
            .map(line => line.trim().toLowerCase())
            .filter(line => line.length > 0 && !line.startsWith("#"));
        
        console.log(`🛡️  Küfür Filtresi Aktif: GitHub'dan ${yasakliKelimeler.length} kelime yüklendi.`);
    } catch (error) {
        console.error("⚠️ Küfür listesi çekilemedi, varsayılan liste kullanılacak.", error.message);
        yasakliKelimeler = ["orospu", "göt", "piç", "oç", "kahpe", "ibne", "amk", "siktir", "fuck", "bitch", "shit"];
    }
};

// İstek geldiğinde çalışan ara katman (middleware)
export const profanityFilter = (req, res, next) => {
    // Taranacak alanlar (frontend'den gelen kullanıcı girdileri)
    const { childName, theme, companion, specialObject, moral } = req.body;
    
    // Sadece metin içeren ve boş olmayan değerleri topla
    const inputsToCheck = [childName, theme, companion, specialObject, moral]
        .filter(val => typeof val === "string" && val.trim().length > 0)
        .map(val => val.toLowerCase());

    for (const input of inputsToCheck) {
        for (const kelime of yasakliKelimeler) {
            // Tam kelime eşleşmesi kontrolü (word boundary)
            // RegExp '\\b' Türkçe karakterlerde bazen sorun yaratabildiği için 
            // kelimeyi boşluklarla çevrili gibi de kontrol ediyoruz.
            const regex = new RegExp(`(?:^|\\s|\\b)${kelime}(?:\\s|\\b|$)`, 'i');
            if (regex.test(input)) {
                console.warn(`🛑 Zararlı içerik engellendi! Hedef: "${input}", Tetikleyen: "${kelime}"`);
                return res.status(400).json({
                    error: "Girdiğiniz bilgilerde uygunsuz kelimeler tespit edildi. Lütfen tekrar deneyin.",
                    code: "PROFANITY_DETECTED"
                });
            }
        }
    }
    
    // Her şey temizse bir sonraki aşamaya (masal oluşturmaya) geç
    next();
};
