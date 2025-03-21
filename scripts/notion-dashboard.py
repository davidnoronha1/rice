import signal
import gi
from pid import PidFile
import pathlib
gi.require_version('Gtk', '3.0')
gi.require_version('WebKit2', '4.1')

from gi.repository import Gtk, WebKit2, Gio, GLib, Gdk

script_path = pathlib.Path(__file__).parent.resolve()
stylesheet_source = """

"""

def store_session(webview):
    session_state = webview.get_session_state()
    session_state_data = session_state.serialize().get_data()

    with open((script_path / 'data.dump').as_posix(), "wb") as f:
        f.write(session_state_data)

    pass

def restore_session(webview):
    with open((script_path / 'data.dump').as_posix(), 'rb') as f:
        content = f.read()
        session_state = WebKit2.WebViewSessionState(GLib.Bytes.new(content))
        webview.restore_session_state(session_state)


class MyWindow(Gtk.Window):
    window_shown = True
    window_position = (0, 0)

    def toggle(self):
        if self.window_shown:
            pos = self.get_position()
            self.window_position = (pos.root_x, pos.root_y)
            self.hide()
        else:
            self.show_all()
            self.move(self.window_position[0], self.window_position[1])
        self.window_shown = not self.window_shown

    def __init__(self):
        Gtk.Window.__init__(self, title="Notion Dashboard")
        self.set_visual(self.get_screen().get_rgba_visual())
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_decorated(False)
        # self.maximize()
        self.set_keep_above(True)
        self.set_default_size(640 * 1.75, 480 * 1.75)

        # Load GTK CSS
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data("window { background-color: white; border-radius: 8px; }")

        Gtk.StyleContext.add_provider_for_screen(self.get_screen(), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)


        # Create a WebKit WebView
        self.webview = WebKit2.WebView()
        self.webview.set_background_color(Gdk.RGBA(0,0,0,0)) # Set webview background transparent
        self.webctx = self.webview.get_context()
        cookie_manager = self.webctx.get_cookie_manager()
        cookie_manager.set_persistent_storage((script_path / "cookies.dump").as_posix(), WebKit2.CookiePersistentStorage.TEXT) # Make cookies persist reload

        stylesheet = WebKit2.UserStyleSheet(stylesheet_source, WebKit2.UserContentInjectedFrames.ALL_FRAMES, WebKit2.UserStyleLevel.USER) 

        content_manager = self.webview.get_user_content_manager()
        content_manager.add_style_sheet(stylesheet)

        if pathlib.Path("./data.dump").exists():
            restore_session(self.webview)
            print("Restored from data dump.")

        self.webview.load_uri("https://www.notion.so/red-herring/5f0c3d01cd6346cf8871473480b54bac?v=4f384f3ab5534ff5a6bdf9603fe44c05&pvs=4")

        self.connect("destroy", Gtk.main_quit)
        self.connect("destroy", lambda _: store_session(self.webview))

        self.scroller = Gtk.ScrolledWindow(hadjustment=None, vadjustment=None)
        self.scroller.add(self.webview)

        self.add(self.scroller)



with PidFile(piddir="/tmp"):
    win = MyWindow()
    signal.signal(signal.SIGUSR1, lambda sig, frame: win.toggle())
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
