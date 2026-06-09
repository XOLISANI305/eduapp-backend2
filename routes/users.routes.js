import express from 'express';
import { requireAuth } from '../middlewares/auth.middleware.js';
import { authorizeRoles } from '../middlewares/authorize.js';
import { 
  getUsers, 
  getUserById, 
  updateUser, 
  deleteUser, 
  updateProfile 
} from '../controllers/users.controller.js';

const router = express.Router();

// ----------------- USER PROFILE ROUTE -----------------
// Only require authentication; any logged-in user can update their own profile
router.put('/me', requireAuth, updateProfile);

// ----------------- ADMIN ROUTES -----------------
router.get('/', requireAuth, authorizeRoles('admin'), getUsers);
router.get('/:id', requireAuth, authorizeRoles('admin'), getUserById);
router.put('/:id', requireAuth, authorizeRoles('admin'), updateUser);
router.delete('/:id', requireAuth, authorizeRoles('admin'), deleteUser);


export default router;