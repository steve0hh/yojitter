# Yojitter

Simple twitter clone with caching for top 10 tweets

## Development instructions

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment instructions

Assumptions:
* Amazon EC2 linux is used
* Security groups are set to allow port 80
* Amazon Linux 2 distro is used.
* Amazon RDS is setup to use postgres with database named `yojitter-prod`

```bash
# install necessary packages
sudo amazon-linux-extras install epel -y
yum install unzip -y
yum install gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf java-1.8.0-openjdk-devel git wget wxBase.x86_64

# install erlang
wget https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_23.2.1-1~centos~7_amd64.rpm
yum install esl-erlang_23.2.1-1~centos~7_amd64.rpm

# install elixir using precompiled binary
cd /usr/bin
mkdir elixir
cd elixir/
wget https://github.com/elixir-lang/elixir/releases/download/v1.11.2/Precompiled.zip
unzip Precompiled.zip

# add elixir binaries to path
echo "export PATH=$PATH:/usr/bin/elixir/bin" >> /ect/profile

# create project folder at /var/www
mkdir /var/www
cd /var/www
git clone https://github.com/steve0hh/yojitter.git
cd yojitter/

# install node and npm to pack assets
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
nvm install node
npm install -g webpack
npm i -g webpack-cli
npm run deploy --prefix ./assets

# compile
mix deps.get --only prod
MIX_ENV=prod mix compile
mix phx.digest

# set the necessary environment variables for production
export SECRET_KEY_BASE=CHANGEME # you can generate secret key via `mix phx.gen.secret`
export DATABASE_URL=ecto://postgres:CHANGEME_POSTGRESQL_PASSWORD@CHANGEME_POSTGRESQL_HOST_URL/yojitter-prod

# create db and migrate
PORT=80 MIX_ENV=prod mix ecto.create
PORT=80 MIX_ENV=prod mix ecto.migrate

# setcap to allow beam to bind to port 80 as non-root user
setcap 'cap_net_bind_service=+ep' /usr/lib/erlang/erts-11.5/bin/beam.smp

# start server in detached mode
PORT=80 MIX_ENV=prod elixir --erl "-detached" -S mix phx.server
```


## Update instructions

```bash
sudo -i # sudo to root

cd /var/www/yojitter

export SECRET_KEY_BASE=CHANGEME # you can generate secret key via `mix phx.gen.secret`
export DATABASE_URL=ecto://postgres:CHANGEME_POSTGRESQL_PASSWORD@CHANGEME_POSTGRESQL_HOST_URL/yojitter-prod

MIX_ENV=prod mix compile
mix phx.digest

exit # change to ec2-user

export SECRET_KEY_BASE=CHANGEME # you can generate secret key via `mix phx.gen.secret`
export DATABASE_URL=ecto://postgres:CHANGEME_POSTGRESQL_PASSWORD@CHANGEME_POSTGRESQL_HOST_URL/yojitter-prod


# optional, kill server process if it's not down yet
# $ ps aux | grep elixir
# 1921
# $ kill 1921

# start server in detached mode
PORT=80 MIX_ENV=prod elixir --erl "-detached" -S mix phx.server
```
