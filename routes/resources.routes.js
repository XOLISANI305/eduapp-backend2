import express from 'express';
import { requireAuth } from '../middlewares/auth.middleware.js';
import { authorizeRoles } from '../middlewares/authorize.js';
import {
  createResource,
  getResourcesByTopic,
  deleteResource
} from '../controllers/resources.controller.js';
import multer from 'multer';
import { v2 as cloudinary } from 'cloudinary';
import { CloudinaryStorage } from 'multer-storage-cloudinary';

const router = express.Router();

// ------------------------ CLOUDINARY SETUP ------------------------
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req, file) => {
    let resourceType = 'auto';
    let folder = 'eduapp/documents';

    if (file.mimetype.startsWith('image/')) {
      folder = 'eduapp/images';
    } else if (file.mimetype.startsWith('video/')) {
      folder = 'eduapp/videos';
      resourceType = 'video';
    } else {
      folder = 'eduapp/docs';
      resourceType = 'raw';
    }

    return {
      folder,
      resource_type: resourceType,
      allowed_formats: [
        'jpg', 'jpeg', 'png', 'gif', 'webp',
        'mp4', 'mov', 'avi', 'mkv',
        'pdf', 'doc', 'docx',
        'xls', 'xlsx', 'csv',
        'ppt', 'pptx',
        'mp3', 'wav', 'm4a',
        'txt',
      ],
    };
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 150 * 1024 * 1024 }, // 150 MB
});

// ------------------------ ROUTES ------------------------
router.get('/topic/:topicId', requireAuth, getResourcesByTopic);

router.post(
  "/",
  requireAuth,
  authorizeRoles("teacher", "admin"),
  (req, res, next) => {
    upload.single("file")(req, res, (err) => {
      if (err) {
        console.log("MULTER ERROR:", err);
        return res.status(500).json({
          message: err.message,
          stack: err,
        });
      }
      next();
    });
  },
  createResource
);

router.delete('/:id', requireAuth, authorizeRoles('teacher', 'admin'), deleteResource);

export default router;
