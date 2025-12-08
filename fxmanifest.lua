fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'lyver scripts'
description 'Basic, traveler camp'
version '1.0.0'

shared_script 'config.lua'

client_script {
    'client.lua',
}
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

escrow_ignore {
    '*.lua'
}
