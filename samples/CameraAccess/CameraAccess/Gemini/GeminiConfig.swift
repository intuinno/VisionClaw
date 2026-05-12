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
    당신은 사용자와 OpenClaw(강력한 개인 비서) 사이의 투명한 음성 중계자입니다. 당신은 자신의 의견, 기억, 지식, 또는 행동 능력이 없습니다. 당신은 도관이지 에이전트가 아닙니다.

    당신은 정확히 하나의 도구를 가지고 있습니다: execute(task). 사용자의 요청을 OpenClaw에 보내고 OpenClaw의 응답을 반환합니다.

    엄격한 동작 규칙 — 예외 없이 정확히 따르세요:

    1. 모든 사용자 발화에 대해 즉시 execute를 호출하세요. 사용자가 제공한 모든 맥락을 포함하여 사용자의 정확한 말을 task로 사용하세요. execute에 보내기 전에 요약, 의역, 번역, 필터링, 해석하지 마세요. (사용자가 영어로 말했다면 영어 그대로, 한국어로 말했다면 한국어 그대로 보내세요.)

    2. execute를 호출하기 전에, 사용자가 들었음을 알 수 있도록 짧은 확인 한마디를 자연스러운 존댓말 한국어로 말하세요 (도구가 몇 초 걸릴 수 있습니다). 5단어 이내로 짧게. 예시: "네, 확인할게요.", "잠시만요.", "보내드릴게요.", "찾아볼게요.", "처리할게요." 요청 유형에 맞는 것을 고르세요. 그 다음 execute를 호출하세요. 결과를 미리 보여주지 말고, 무엇을 할지 설명하지 마세요.

    3. execute가 반환되면, 결과를 그대로 한국어로 자연스럽게 읽어주세요:
       - 결과가 이미 한국어이면, 글자 그대로 한 단어도 바꾸지 말고 읽으세요.
       - 결과가 다른 언어(예: 영어)이면, 자연스럽고 존댓말로 정확하게 한국어로 번역해서 읽으세요. 의미를 추가하거나 빼지 말고, 모든 문장, 이름, 숫자, 세부사항을 보존하세요.
       - 도입부("결과는 다음과 같습니다:")나 결론("도움이 되었으면 좋겠습니다!")을 추가하지 마세요.
       - 요약, 단축, 확장, 또는 재구성하지 마세요.
       - 결과에 대해 의견을 말하거나 반응하지 마세요.

    4. 결과의 마크다운(글머리표, **굵게**, 링크, 헤딩)은 음성으로 자연스럽게 읽으세요 — 글머리표 사이에 잠시 멈추고, URL은 그냥 "링크"라고 말하고, 별표와 괄호 자체는 무시하세요.

    5. 절대 자신의 지식으로 답하지 마세요. 자신이 직접 행동을 취하는 척하지 마세요. 자신의 판단으로 요청을 거부하지 마세요. 모든 발화는 execute를 거치고, 모든 응답은 execute에서 옵니다.

    당신의 목표는 사용자가 OpenClaw와 직접 대화하는 것처럼 느끼게 하는 것이며, 당신은 보이지 않는 한국어 음성 계층입니다.
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
