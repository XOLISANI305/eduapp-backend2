import Resource from '../models/resource.model.js';
import { v2 as cloudinary } from 'cloudinary';
import SubscriptionService from "../services/subscriptionService.js";

// Create resource
export const createResource = async (req, res) => {
  try {
    console.log('Request body:', req.body);
    console.log('File info:', req.file);

    const { topic_id, type, title, url } = req.body;

    if (!topic_id || !type || !title) {
      return res.status(400).json({
        message: 'Missing required fields',
        required: ['topic_id', 'type', 'title']
      });
    }

    if (!req.file && !url) {
      return res.status(400).json({
        message: 'Either file upload or URL is required'
      });
    }

    // Cloudinary returns the file URL in req.file.path
    const fileUrl = req.file ? req.file.path : null;
    const cloudinaryPublicId = req.file ? req.file.filename : null;

    const newResource = await Resource.create({
      topic_id: parseInt(topic_id),
      type,
      title,
      file_path: fileUrl,           // now a permanent Cloudinary URL
      cloudinary_id: cloudinaryPublicId, // store for deletion later
      url: url || null
    });

    console.log('Resource created successfully:', newResource);
    res.status(201).json(newResource);
  } catch (err) {
    console.error('Error creating resource:', err);
    res.status(500).json({
      message: 'Server error',
      error: err.message
    });
  }
};

// Delete resource
export const deleteResource = async (req, res) => {
  try {
    const { id } = req.params;

    const resource = await Resource.delete(id);
    if (!resource) return res.status(404).json({ message: 'Resource not found' });

    // Delete from Cloudinary if it has a cloudinary_id
    if (resource.cloudinary_id) {
      try {
        await cloudinary.uploader.destroy(resource.cloudinary_id, {
          resource_type: resource.type === 'video' ? 'video' : 
                         resource.type === 'image' ? 'image' : 'raw'
        });
        console.log('File deleted from Cloudinary:', resource.cloudinary_id);
      } catch (cloudinaryError) {
        console.error('Failed to delete from Cloudinary:', cloudinaryError);
        // Don't fail the request if Cloudinary deletion fails
      }
    }

    res.json({ message: 'Resource deleted successfully' });
  } catch (err) {
    console.error('Error deleting resource:', err);
    res.status(500).json({
      message: 'Server error',
      error: err.message
    });
  }
};

// Get resources by topic
// Get resources by topic
export const getResourcesByTopic = async (req, res) => {
  try {

    const { topicId } = req.params;
    const userId = req.user.id;

    if (!topicId) {
      return res.status(400).json({
        message: "Topic ID is required"
      });
    }

    const resources = await Resource.getByTopic(parseInt(topicId));

    // Check subscription once
    const canDownload =
      await SubscriptionService.canDownload(userId);

    const videoLimit =
      await SubscriptionService.getVideoLimit(userId);

    // Add lock status to each resource
    for (const resource of resources) {

      resource.locked = false;

      // Word documents
     // Premium downloadable files
if (
  resource.type === "word" ||
  resource.type === "document"
) {
  resource.locked = !canDownload;
}

// PDFs are available to everyone
if (resource.type === "pdf") {
  resource.locked = false;
}

// Videos (we'll enforce limits next)
if (resource.type === "video") {
  resource.locked = false;
}

      // Videos
      if (resource.type === "video") {

        if (videoLimit !== null) {
          resource.locked = false; // we'll enforce limits later
        }

      }

    }

    console.log(
      `Found ${resources.length} resources for topic ${topicId}`
    );

    res.json(resources);

  } catch (err) {

    console.error("Error getting resources:", err);

    res.status(500).json({
      message: "Server error",
      error: err.message
    });

  }
};