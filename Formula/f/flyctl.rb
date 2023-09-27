class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.1.103",
      revision: "e091df05ab9d089443f3812b593a1c3350f9b3fb"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  # Upstream tags versions like `v0.1.92` and `v2023.9.8` but, as of writing,
  # they only create releases for the former and those are the versions we use
  # in this formula. We could omit the date-based versions using a regex but
  # this uses the `GithubLatest` strategy, as the upstream repository also
  # contains over a thousand tags (and growing).
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "77b6773f4cbe2e359003e87d263a556afa56214bc85d47f4d4c343640b6bdadb"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "77b6773f4cbe2e359003e87d263a556afa56214bc85d47f4d4c343640b6bdadb"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "77b6773f4cbe2e359003e87d263a556afa56214bc85d47f4d4c343640b6bdadb"
    sha256 cellar: :any_skip_relocation, sonoma:         "c71e8ba1b3e7128c708518f5ab80f15acd938d3344a256dac5eaf88126f53414"
    sha256 cellar: :any_skip_relocation, ventura:        "c71e8ba1b3e7128c708518f5ab80f15acd938d3344a256dac5eaf88126f53414"
    sha256 cellar: :any_skip_relocation, monterey:       "c71e8ba1b3e7128c708518f5ab80f15acd938d3344a256dac5eaf88126f53414"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d4d5e1a5ab056355794f677a555f16a2ce628b447ba410eda1235df3180e9153"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.environment=production
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.version=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags)

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("#{bin}/flyctl status 2>&1", 1)
    assert_match "Error: No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
