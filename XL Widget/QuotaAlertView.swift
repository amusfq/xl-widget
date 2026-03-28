import SwiftUI

struct QuotaAlertView: View {
    let remaining: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Low Data Alert")
                    .font(.headline)
                
                Text("Your remaining XL data is low:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(remaining)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            Button("Dismiss") {
                onDismiss()
            }
            .keyboardShortcut(.defaultAction)
            .controlSize(.large)
        }
        .padding(30)
        .frame(width: 300)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
