import CoreTransferable
import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// The card, the drinks toggle, and a share of the rendered image.
///
/// The toggle starts on each time this screen opens. It is not saved.
/// The image is written to a temporary file when sharing needs a URL. It is not kept in Documents.
struct WeekCardShareView: View {
    let seal: WeekSeal

    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    @State private var includeDrinks = true
    @State private var sharedFile: WeekCardFile?
    @State private var previewImage: UIImage?
    @State private var renderErrorMessage: String?
    @State private var isShowingRenderError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                column
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DesignSystem.Colors.background)
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: renderCard)
        .onChange(of: includeDrinks) { _, _ in
            renderCard()
        }
        .alert("Your change couldn't be saved", isPresented: $isShowingRenderError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(renderErrorMessage ?? "Please try again.")
        }
    }

    /// Preview scale so the fixed 360-point card fits a phone, padding included. The shared image stays full size.
    private var previewScale: CGFloat { 0.86 }

    private var column: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            WeekCardView(seal: seal, includeDrinks: includeDrinks)
                .scaleEffect(previewScale, anchor: .top)
                .frame(width: WeekCardView.width * previewScale, height: WeekCardView.height * previewScale)
            Toggle("Include drinks", isOn: $includeDrinks)
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .tint(DesignSystem.Colors.teal)
            shareControl
        }
        .padding(DesignSystem.Spacing.lg)
    }

    @ViewBuilder
    private var shareControl: some View {
        if let sharedFile, let previewImage {
            ShareLink(
                item: sharedFile,
                preview: SharePreview(seal.season.title, image: Image(uiImage: previewImage))
            ) {
                Text("Share")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.surfaceHigh, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("week.card.share")
        }
    }

    /// Rebuilds the picture before the system sheet can open.
    private func renderCard() {
        let renderer = ImageRenderer(content: renderedCard)
        renderer.scale = displayScale
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(width: WeekCardView.width, height: WeekCardView.height)
        guard let image = renderer.uiImage, let data = image.pngData() else {
            sharedFile = nil
            previewImage = nil
            renderErrorMessage = nil
            isShowingRenderError = true
            return
        }
        do {
            let url = try WeekCardImageFile.write(data)
            previewImage = image
            sharedFile = WeekCardFile(url: url)
            isShowingRenderError = false
        } catch {
            sharedFile = nil
            previewImage = nil
            renderErrorMessage = error.localizedDescription
            isShowingRenderError = true
        }
    }

    private var renderedCard: some View {
        WeekCardView(seal: seal, includeDrinks: includeDrinks)
            .environment(\.colorScheme, .dark)
    }
}

/// A PNG of the week card handed to `ShareLink`.
struct WeekCardFile: Transferable, Sendable {
    var url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .png) { card in
            SentTransferredFile(card.url)
        } importing: { received in
            WeekCardFile(url: received.file)
        }
    }
}

/// One temporary PNG. Each render replaces it. Nothing is written under Documents.
enum WeekCardImageFile {
    static let fileName = "streakline-week.png"

    static var url: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(fileName, isDirectory: false)
    }

    static func write(_ data: Data) throws -> URL {
        let destination = url
        try data.write(to: destination, options: .atomic)
        return destination
    }
}
