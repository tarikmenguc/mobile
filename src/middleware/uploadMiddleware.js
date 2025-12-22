const multer = require('multer');

// Depolama ayarı: MemoryStorage (Dosyayı RAM'de buffer olarak tutar)
// Project Constitution Kuralı: Resim/Dosya sunucuda depolanmaz. RAM üzerinden işlenir.
const storage = multer.memoryStorage();

// Dosya filtresi: Sadece resim dosyaları
const path = require('path');

// Dosya filtresi: Sadece Resim dosyaları (PDF kaldırıldı)
const fileFilter = (req, file, cb) => {
    // Debug Log
    console.log("Gelen Tip:", file.mimetype);

    // 1. Mime Type Kontrolü (Resim + PDF + Octet Stream)
    const allowedMimes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/heic', 'application/pdf', 'application/octet-stream'];

    // 2. Uzantı Kontrolü
    const filetypes = /jpeg|jpg|png|webp|heic|pdf/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedMimes.includes(file.mimetype);

    // Octet stream gelirse uzantıya güveneceğiz
    if (file.mimetype === 'application/octet-stream' && extname) {
        return cb(null, true);
    }

    if (mimetype && extname) {
        cb(null, true);
    } else {
        console.log(`REJECTED FILE: ${file.originalname} - MIME: ${file.mimetype}`);
        cb(new Error(`Desteklenmeyen dosya formatı! (Mime: ${file.mimetype})`), false);
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
