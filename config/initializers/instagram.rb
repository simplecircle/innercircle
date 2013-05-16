if Rails.env == "development" or Rails.env == "test"
  CLIENT_ID = "5d725bcbda1f4c0bb5521c01b2d4a7db"
  CLIENT_SECRET = "a65abd78048e4d779237b155b031b094"
  OAUTH_CALLBACK = "http://pslocal.me/app/ig/oauth"
else
  CLIENT_ID = "fa127cd5a6794db2a529657e9130c16d"
  CLIENT_SECRET = "0546a00075ba493d9ab253cf9c61d427"
  OAUTH_CALLBACK = "http://puppystream.me/app/ig/oauth"
end
