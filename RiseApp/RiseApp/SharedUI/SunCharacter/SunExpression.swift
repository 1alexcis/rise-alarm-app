import Foundation

enum SunExpression {
    case waving       // onboarding — one ray extended and "waving"
    case neutral      // app icon / default state
    case sleepy       // alarm not yet dismissed — half-closed eyes
    case happy        // streak / celebration — big smile
    case sad          // missed alarm — drooping rays, frown
    case celebrating  // milestone reached — rays spinning fast
}
