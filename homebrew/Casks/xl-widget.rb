cask "xl-widget" do
  version "1.0.0" # This should match the GitHub Release tag
  sha256 :no_check # This will be updated with the output from the GitHub Action

  url "https://github.com/amusfq/xl-widget/releases/download/v#{version}/XLWidget.dmg"
  name "XL Widget"
  desc "Lightweight native macOS menu bar utility for XL Axiata"
  homepage "https://github.com/amusfq/xl-widget"

  app "XL Widget.app"

  # As it's unsigned, we need to handle the quarantine flag or mention it in caveats
  caveats <<~EOS
    Since this app is not signed by a verified Apple Developer, you may need to run:
      xattr -cr /Applications/XL\\ Widget.app
    after the first install if it shows a "Damaged" error.
  EOS
end
