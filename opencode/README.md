# Default Configuration

This directory contains default configuration files for the opencode template.

## default-config.json

The main configuration file using GLM 4.5 Air (free tier) as the primary model:

```json
{
  "agents": {
    "planner": {
      "model": "z-ai/glm-4.5-air:free",
      "fallback": "google/gemini-2.0-flash-exp:free",
      "temperature": 0.3,
      "max_tokens": 4000
    },
    "builder": {
      "model": "z-ai/glm-4.5-air:free", 
      "fallback": "google/gemini-2.0-flash-exp:free",
      "temperature": 0.5,
      "max_tokens": 4000
    },
    "reviewer": {
      "model": "google/gemini-2.0-flash-exp:free",
      "temperature": 0.2,
      "max_tokens": 3000
    },
    "web_searcher": {
      "model": "google/gemini-2.0-flash-exp:free",
      "temperature": 0.4,
      "max_tokens": 3000
    }
  },
  "defaults": {
    "primary_model": "z-ai/glm-4.5-air:free",
    "fallback_model": "google/gemini-2.0-flash-exp:free"
  }
}
```

## Usage

Copy this configuration to your project's `.git/opencode` file to use the default GLM 4.5 Air setup:

```bash
cp opencode/default-config.json .git/opencode
```

## Model Details

### GLM 4.5 Air (Free Tier)
- **Provider**: OpenRouter via z-ai
- **Model**: `z-ai/glm-4.5-air:free`
- **Cost**: Free tier available
- **Use cases**: Planning, building, general coding tasks

### Gemini 2.0 Flash (Free Tier)
- **Provider**: Google
- **Model**: `google/gemini-2.0-flash-exp:free`
- **Cost**: Free tier available
- **Use cases**: Reviews, web searching, documentation

## Environment Variables Required

```bash
export OPENROUTER_API_KEY="your-openrouter-key"
export GEMINI_API_KEY="your-gemini-key"
```

## Configuration Override

To override specific agents, modify the `.git/opencode` file directly or create a custom configuration file.