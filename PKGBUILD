# Maintainer: TinoTheCuteDuck tinothecuteduck@gmail.com

pkgname=login-greeter
pkgver=1.0.0
pkgrel=1
pkgdesc="A simple Qt6 QML login greeter"
arch=('x86_64')
url="https://github.com/TinoTheCuteDuck/Login-Greeter"

depends=(
    'qt6-base'
    'qt6-declarative'
    'qt6-multimedia'
    'qt6-5compat'
)

source=(
    "LoginGreeter::https://github.com/TinoTheCuteDuck/Login-Greeter/releases/download/v${pkgver}/Login-Greeter"
)

sha256sums=('SKIP')

package() {
    install -Dm755 \
        "$srcdir/LoginGreeter" \
        "$pkgdir/usr/bin/login-greeter"
}