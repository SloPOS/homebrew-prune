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

      export PATH="#{Formula["node@20"].opt_bin}:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/bin:/home/bit/.local/bin:/usr/bin:/bin:/home/bit/.nvm/current/bin:/home/bit/.npm-global/bin:/home/bit/bin:/home/bit/.fnm/current/bin:/home/bit/.volta/bin:/home/bit/.asdf/shims:/home/bit/.local/share/pnpm:/home/bit/.bun/bin"

      PRUNE_DATA_ROOT="#{var/prune}"
      mkdir -p ""/{media,archive,uploads,transcripts,projects,exports}

      export HOST="0.0.0.0"
      export PORT="4173"
      export PRUNE_INBOX_ROOT="/media"
      export PRUNE_ARCHIVE_ROOT="/archive"
      export PRUNE_UPLOAD_DIR="/uploads"
      export PRUNE_TRANSCRIPT_DIR="/transcripts"
      export PRUNE_PROJECTS_DIR="/projects"
      export PRUNE_EXPORT_DIR="/exports"
      export PRUNE_SETTINGS_PATH="/config.json"

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

  test do
    assert_match "v20", shell_output("#{Formula["node@20"].opt_bin}/node -v")
  end
end
