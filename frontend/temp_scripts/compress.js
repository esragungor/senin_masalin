const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const targetDir = 'c:/Users/esgng/OneDrive/Desktop/senin-masalin/frontend/assets';

let totalBefore = 0;
let totalAfter = 0;
let count = 0;

async function processDirectory(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
            await processDirectory(fullPath);
        } else if (/\.(jpg|jpeg|png)$/i.test(fullPath)) {
            const sizeBefore = stat.size;
            totalBefore += sizeBefore;
            const tempPath = fullPath + '.tmp';
            try {
                const img = sharp(fullPath);
                const meta = await img.metadata();

                const isJpeg = /\.(jpg|jpeg)$/i.test(fullPath);
                let pipeline = img.resize({ width: 512, height: 512, fit: 'inside', withoutEnlargement: true });

                if (isJpeg) {
                    pipeline = pipeline.jpeg({ quality: 75, mozjpeg: true });
                } else {
                    pipeline = pipeline.png({ quality: 75, compressionLevel: 9 });
                }

                await pipeline.toFile(tempPath);
                const sizeAfter = fs.statSync(tempPath).size;
                fs.unlinkSync(fullPath);
                fs.renameSync(tempPath, fullPath);
                totalAfter += sizeAfter;
                count++;
                if (count % 20 === 0) console.log(`${count} resim işlendi... Şimdiye kadar: ${(totalBefore/1024/1024).toFixed(0)} MB -> ${(totalAfter/1024/1024).toFixed(0)} MB`);
            } catch (e) {
                if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
                totalAfter += sizeBefore; // sayma
                console.error(`Hata: ${file} - ${e.message}`);
            }
        }
    }
}

processDirectory(targetDir).then(() => {
    console.log(`\nTamamlandı! ${count} resim işlendi.`);
    console.log(`Önce: ${(totalBefore/1024/1024).toFixed(1)} MB`);
    console.log(`Sonra: ${(totalAfter/1024/1024).toFixed(1)} MB`);
    console.log(`Kazanç: ${((totalBefore-totalAfter)/1024/1024).toFixed(1)} MB (%${(100*(totalBefore-totalAfter)/totalBefore).toFixed(0)})`);
}).catch(console.error);
