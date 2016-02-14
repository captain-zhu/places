# -*- encoding: utf-8 -*-
# stub: mongo 2.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "mongo"
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tyler Brock", "Emily Stolfo", "Durran Jordan"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDfDCCAmSgAwIBAgIBATANBgkqhkiG9w0BAQUFADBCMRQwEgYDVQQDDAtkcml2\nZXItcnVieTEVMBMGCgmSJomT8ixkARkWBTEwZ2VuMRMwEQYKCZImiZPyLGQBGRYD\nY29tMB4XDTE0MTEyMDE1NTYxOVoXDTE1MTEyMDE1NTYxOVowQjEUMBIGA1UEAwwL\nZHJpdmVyLXJ1YnkxFTATBgoJkiaJk/IsZAEZFgUxMGdlbjETMBEGCgmSJomT8ixk\nARkWA2NvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANFdSAa8fRm1\nbAM9za6Z0fAH4g02bqM1NGnw8zJQrE/PFrFfY6IFCT2AsLfOwr1maVm7iU1+kdVI\nIQ+iI/9+E+ArJ+rbGV3dDPQ+SLl3mLT+vXjfjcxMqI2IW6UuVtt2U3Rxd4QU0kdT\nJxmcPYs5fDN6BgYc6XXgUjy3m+Kwha2pGctdciUOwEfOZ4RmNRlEZKCMLRHdFP8j\n4WTnJSGfXDiuoXICJb5yOPOZPuaapPSNXp93QkUdsqdKC32I+KMpKKYGBQ6yisfA\n5MyVPPCzLR1lP5qXVGJPnOqUAkvEUfCahg7EP9tI20qxiXrR6TSEraYhIFXL0EGY\nu8KAcPHm5KkCAwEAAaN9MHswCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0O\nBBYEFFt3WbF+9JpUjAoj62cQBgNb8HzXMCAGA1UdEQQZMBeBFWRyaXZlci1ydWJ5\nQDEwZ2VuLmNvbTAgBgNVHRIEGTAXgRVkcml2ZXItcnVieUAxMGdlbi5jb20wDQYJ\nKoZIhvcNAQEFBQADggEBAKjvumG2Fy9zAoSc1OEcmAqqOfzx1U+isGyEsz1rs5eT\nHAIHsxaEdZTjSwDuqyelLDWJHWspeWU5pV5lepfI4cop29wwoPJIJ9Az2RMMbtdv\ngFApVb6QX61OMenFeOdJ/QZ3n9xcrxJZFdvrXQ5GjEU2anq3dJhFeESwIMlfVJC7\n7XrlMxizzH712DPfy65dMj0Y39qHdoWYKeCkEoj5UWNcHRK9xgaHJR6prlXrIhgb\no2UXDbWtz5PqoFd8EgNJAn3+BG1pwC9S9pVFG3WPucfAx/bE8iq/vvchHei5Y/Vo\naAz5f/hY4zFeYWvGDBHYEXE1rTN2hhMSyJscPcFbmz0=\n-----END CERTIFICATE-----\n"]
  s.date = "2015-10-16"
  s.description = "A Ruby driver for MongoDB"
  s.email = "mongodb-dev@googlegroups.com"
  s.homepage = "http://www.mongodb.org"
  s.licenses = ["Apache License Version 2.0"]
  s.rubyforge_project = "mongo"
  s.rubygems_version = "2.4.5.1"
  s.summary = "Ruby driver for MongoDB"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bson>, ["~> 3.0"])
    else
      s.add_dependency(%q<bson>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<bson>, ["~> 3.0"])
  end
end
