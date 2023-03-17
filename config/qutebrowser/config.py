import catppuccin

# load your autoconfig, use this if the rest of your config is empty!
config.load_autoconfig()
# c.url.default_page = 'https://www.google.com'
# c.url.start_pages = ['https://www.google.com']
# set the flavour you'd like to use
# valid options are 'mocha', 'macchiato', 'frappe', and 'latte'
catppuccin.setup(c, 'macchiato')
