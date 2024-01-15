fx_version 'cerulean'
game 'gta5'

description 'qb-rental'
version '1.0.0'
lua54 'yes'


client_script {
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
    'client/client.lua',
}

server_script {
    'server/server.lua'
}

ui_page 'html/index.html'


shared_scripts {
	'@qb-core/shared/locale.lua',
	'config.lua'
}

files {
    'html/index.html',
    'html/styles.css',
    'html/ui.js',
    'html/reset.css',
    'html/img/*.jpg',
}

escrow_ignore {
    'locales/locale.lua',
    'locales/en.lua',
    'config.lua',
}