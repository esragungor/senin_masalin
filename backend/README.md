# Senin Masalın - Backend API

Backend API for the Senin Masalın mobile application.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file from `.env.example`:
```bash
cp .env.example .env
```

3. Add your API keys to `.env`

4. Run development server:
```bash
npm run dev
```

## API Endpoints

### Authentication
- `POST /api/auth/google` - Google Sign-In
- `GET /api/auth/profile` - Get user profile

### Stories
- `POST /api/stories/create` - Create new story
- `GET /api/stories/:id` - Get story by ID
- `GET /api/stories/user/:userId` - Get user's stories
- `DELETE /api/stories/:id` - Delete story
- `PATCH /api/stories/:id/favorite` - Toggle favorite
- `PATCH /api/stories/:id/progress` - Update reading progress

### Achievements
- `GET /api/achievements/:userId` - Get user achievements
- `POST /api/achievements/unlock` - Unlock achievement
