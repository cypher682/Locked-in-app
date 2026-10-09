# API Endpoints Reference

Base URL: `http://localhost:8000/api/v1` (Development)

## Authentication
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| POST | `/auth/login` | Login with Firebase token | No |
| POST | `/auth/register` | Register new user | No |

## User Profile
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| GET | `/profile/me` | Get current user profile | Yes |
| GET | `/users/search` | Search users by query | Yes |
| GET | `/users/:id` | Get specific user profile | Yes |
| PUT | `/profile/me` | Update profile details | Yes |

## Goals
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| GET | `/goals` | Get user's goals | Yes |
| POST | `/goals` | Create a new goal | Yes |
| GET | `/goals/:id` | Get goal details | Yes |
| PUT | `/goals/:id` | Update a goal | Yes |
| DELETE | `/goals/:id` | Delete a goal | Yes |

## Check-ins
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| GET | `/checkins` | Get user's check-ins | Yes |
| POST | `/checkins` | Create a check-in | Yes |
| GET | `/checkins/:id` | Get check-in details | Yes |
| DELETE | `/checkins/:id` | Delete a check-in | Yes |
| GET | `/goals/:id/checkins` | Get check-ins for a goal | Yes |
| GET | `/streak` | Get current streak info | Yes |

## Social & Friends
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| GET | `/friends` | Get friends list | Yes |
| POST | `/friends/requests` | Send friend request | Yes |
| POST | `/friends/requests/:id/accept` | Accept friend request | Yes |
| POST | `/friends/requests/:id/decline` | Decline friend request | Yes |
| GET | `/friends/requests/pending` | Get pending requests | Yes |

## Activity Feed
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| GET | `/feed` | Get activity feed (friends + public) | Yes |

## Likes & Comments
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| POST | `/checkins/:id/like` | Like a check-in | Yes |
| DELETE | `/checkins/:id/like` | Unlike a check-in | Yes |
| GET | `/checkins/:id/likes` | Get users who liked | Yes |
| GET | `/checkins/:id/comments` | Get comments | Yes |
| POST | `/checkins/:id/comments` | Add a comment | Yes |
| DELETE | `/comments/:id` | Delete a comment | Yes |

## Gamification

### Points
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| GET | `/points` | Get total points + recent history | Yes |
| GET | `/points/history` | Get full point transaction history | Yes |

### Leaderboard
| Method | Endpoint | Description | Query Params |
|:---|:---|:---|:---|
| GET | `/leaderboard` | Get rankings | `scope=global|friends`, `limit=50` |

### Achievements
| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| GET | `/achievements` | Get all available badges | Yes |
| GET | `/achievements/mine` | Get user's unlocked badges | Yes |
