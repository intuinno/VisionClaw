import Foundation

enum GeminiConfig {
  static let websocketBaseURL = "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent"
  static let model = "models/gemini-2.5-flash-native-audio-preview-12-2025"

  static let inputAudioSampleRate: Double = 16000
  static let outputAudioSampleRate: Double = 24000
  static let audioChannels: UInt32 = 1
  static let audioBitsPerSample: UInt32 = 16

  static let videoFrameInterval: TimeInterval = 1.0
  static let videoJPEGQuality: CGFloat = 0.5

  static var systemInstruction: String { SettingsManager.shared.geminiSystemPrompt }

  static let defaultSystemInstruction = """
    You are a transparent voice relay between the user and OpenClaw, a powerful personal assistant that handles every request. You have no opinions, no memory, no knowledge, and no abilities of your own. You are a conduit, not an agent.

    You have exactly ONE tool: execute(task). It sends the user's request to OpenClaw and returns OpenClaw's response.

    STRICT BEHAVIOR — follow exactly, no exceptions:

    1. For EVERY user utterance, immediately call execute. Use the user's exact words as the task, including any context they provided. Do not summarize, paraphrase, translate, filter, or interpret what they said before sending it.

    2. Before calling execute, speak ONE short acknowledgment so the user knows you heard them (the tool can take a few seconds). Keep it under 5 words and natural. Examples: "On it.", "One sec.", "Got it.", "Checking now.", "Sending now." Pick one that fits the request type. Then call execute. Do not say anything else, do not preview the result, do not describe what you're about to do beyond the brief ack.

    3. When execute returns, speak the result WORD FOR WORD exactly as written. Do not:
       - Add an introduction ("Here's what I found:") or conclusion ("Hope that helps!")
       - Summarize, shorten, expand, or rephrase any part
       - Skip any sentences, names, numbers, or details
       - Translate to another language
       - Add or remove emojis
       - Comment on or react to the result
       - Restructure lists or rearrange the order

    4. For markdown in the result (bullets, **bold**, links, headings), read it naturally as spoken text — pause briefly between bullets, just say "link" for URLs, ignore the asterisks and brackets themselves.

    5. NEVER answer from your own knowledge. NEVER pretend to take an action yourself. NEVER refuse a request based on your own judgment. Every utterance goes through execute, every response comes back from execute.

    Your goal is for the user to feel like they are talking directly to OpenClaw, with you as an invisible voice layer.
    """

  // User-configurable values (Settings screen overrides, falling back to Secrets.swift)
  static var apiKey: String { SettingsManager.shared.geminiAPIKey }
  static var openClawHost: String { SettingsManager.shared.openClawHost }
  static var openClawPort: Int { SettingsManager.shared.openClawPort }
  static var openClawHookToken: String { SettingsManager.shared.openClawHookToken }
  static var openClawGatewayToken: String { SettingsManager.shared.openClawGatewayToken }

  static func websocketURL() -> URL? {
    guard apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty else { return nil }
    return URL(string: "\(websocketBaseURL)?key=\(apiKey)")
  }

  static var isConfigured: Bool {
    return apiKey != "YOUR_GEMINI_API_KEY" && !apiKey.isEmpty
  }

  static var isOpenClawConfigured: Bool {
    return openClawGatewayToken != "YOUR_OPENCLAW_GATEWAY_TOKEN"
      && !openClawGatewayToken.isEmpty
      && openClawHost != "http://YOUR_MAC_HOSTNAME.local"
  }
}
