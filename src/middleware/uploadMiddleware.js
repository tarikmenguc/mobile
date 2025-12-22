const multer = require('multer');

// Depolama ayarı: MemoryStorage (Dosyayı RAM'de buffer olarak tutar)
// Project Constitution Kuralı: Resim/Dosya sunucuda depolanmaz. RAM üzerinden işlenir.
const storage = multer.memoryStorage();

// Dosya filtresi: Sadece resim dosyaları
const path = require('path');

// Dosya filtresi: Resim dosyaları
const fileFilter = (req, file, cb) => {
    // 1. Mime Type Kontrolü (PDF Eklendi)
    const allowedMimes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/heic', 'application/pdf'];

    // 2. Uzantı Kontrolü (Fallback)
    const filetypes = /jpeg|jpg|png|webp|heic|pdf/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedMimes.includes(file.mimetype);

    if (mimetype || extname) {
        cb(null, true);
    } else {
        console.log(`REJECTED FILE: ${file.originalname} - MIME: ${file.mimetype}`);
        cb(new Error(`Sadece resim dosyası yükleyebilirsiniz! (Gelen: ${file.mimetype})`), false);
    }
};

const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024 // Maksimum 5MB
    }
});

module.exports = upload;
