class Prune < Formula
  desc "Transcript-first video editor for self-hosted workflows"
  homepage "https://github.com/SloPOS/Prune"
  url "https://github.com/SloPOS/Prune/archive/528216b829b42c77cd9fb03c76a5f6bc736b9a6d.tar.gz"
  version "0.0.1"
  sha256 "3929a3ed547dde7a2c8319e9f19e6a0347fc8ac98232c7b67044660a28d7770b"
  license "MIT"

  depends_on "node@20"
  depends_on "python"
  depends_on "ffmpeg"

  def install
    libexec.install Dir["*"]

    cd libexec do
      system Formula["node@20"].opt_bin/"npm", "install"
      system Formula["node@20"].opt_bin/"npm", "run", "build"
    end

    (bin/"prune").write <<~SH
      #!/bin/bash
      set -euo pipefail

      export PATH="#{Formula["node@20"].opt_bin}:$PATH"

      PRUNE_DATA_ROOT="${PRUNE_DATA_ROOT:-#{var}/prune}"
      mkdir -p "$PRUNE_DATA_ROOT"/{media,archive,uploads,transcripts,projects,exports}

      export HOST="${HOST:-0.0.0.0}"
      export PORT="${PORT:-4173}"
      export PRUNE_INBOX_ROOT="${PRUNE_INBOX_ROOT:-$PRUNE_DATA_ROOT/media}"
      export PRUNE_ARCHIVE_ROOT="${PRUNE_ARCHIVE_ROOT:-$PRUNE_DATA_ROOT/archive}"
      export PRUNE_UPLOAD_DIR="${PRUNE_UPLOAD_DIR:-$PRUNE_DATA_ROOT/uploads}"
      export PRUNE_TRANSCRIPT_DIR="${PRUNE_TRANSCRIPT_DIR:-$PRUNE_DATA_ROOT/transcripts}"
      export PRUNE_PROJECTS_DIR="${PRUNE_PROJECTS_DIR:-$PRUNE_DATA_ROOT/projects}"
      export PRUNE_EXPORT_DIR="${PRUNE_EXPORT_DIR:-$PRUNE_DATA_ROOT/exports}"
      export PRUNE_SETTINGS_PATH="${PRUNE_SETTINGS_PATH:-$PRUNE_DATA_ROOT/config.json}"

      exec "#{Formula["node@20"].opt_bin}/node" "#{libexec}/apps/media-api/prod-server.mjs"
    SH
  end

  service do
    run [opt_bin/"prune"]
    keep_alive true
    working_dir var
    log_path var/"log/prune.log"
    error_log_path var/"log/prune.error.log"
  end

  def caveats
    <<~EOS
      Start Prune:
        prune

      Then open in your browser:
        http://localhost:4173

      Or run as a background service:
        brew services start prune
    EOS
  end

  test do
    assert_match "v20", shell_output("#{Formula["node@20"].opt_bin}/node -v")
  end
end
