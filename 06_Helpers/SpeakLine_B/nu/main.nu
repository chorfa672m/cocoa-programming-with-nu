(import Cocoa)		;; bridgesupport
(load "console")	;; interactive console

(class AppController is NSObject
     (ivar (id) textField (id) speechSynth (id) stopButton (id) startButton (id) voiceList (id) tableView)
     
     (- (id) init is
        (super init)
		;; Set the global variable $ac equal to the appController for easy access in the console.
        (set $ac self)
        (set @speechSynth ((NSSpeechSynthesizer alloc) initWithVoice:nil))
        (@speechSynth setDelegate:self)
		(set @voiceList (NSSpeechSynthesizer availableVoices))
        self)
     
     (- (void) awakeFromNib is
        (set defaultVoice (NSSpeechSynthesizer defaultVoice))
        (set defaultRow (@voiceList indexOfObject:defaultVoice))
        (@tableView selectRow:defaultRow byExtendingSelection:NO)
        (@tableView scrollRowToVisible:defaultRow))

     (- (void) sayIt: (id) sender is
        (set string (@textField stringValue))
        (unless (eq 0 (string length))
                (@speechSynth startSpeakingString:string)
                (NSLog "Have started to say #{string}")
                (@stopButton setEnabled:YES)
                (@startButton setEnabled:NO)
				(@tableView setEnabled:NO)))
     
     (- (void) stopIt: (id) sender is
        (NSLog "stopping")
        (@speechSynth stopSpeaking))
     
     (- (void) speechSynthesizer: (id) sender didFinishSpeaking: (BOOL) finishedNormally is
        (NSLog "didFinish:#{finishedNormally}")
        (@stopButton setEnabled:NO)
        (@startButton setEnabled:YES)
		(@tableView setEnabled:YES))

     (- (void) tableViewSelectionDidChange: (id) note is
        (set row (@tableView selectedRow))
        (unless (eq row -1)
                (set selectedVoice (@voiceList row))
                (@speechSynth setVoice:selectedVoice)
                (NSLog "new voice = #{selectedVoice}")))

     (- (int) numberOfRowsInTableView: (id) tv is
        (@voiceList count))

     (- (id) tableView: (id) tv objectValueForTableColumn: (id) tc row: (int) row is
        (set dict (NSSpeechSynthesizer attributesForVoice:(@voiceList row)))
		(dict objectForKey:NSVoiceName)))

(set SHOW_CONSOLE_AT_STARTUP nil)

;; @class ApplicationDelegate
;; @discussion Methods of this class perform general-purpose tasks that are not appropriate methods of any other classes.
(class ApplicationDelegate is NSObject
     
     ;; This method is called after Cocoa has finished its basic application setup.
     ;; It instantiates application-specific components.
     ;; In this case, it constructs an interactive Nu console that can be activated from the application's Window menu.
     (- (void) applicationDidFinishLaunching:(id) sender is
        (set $console ((NuConsoleWindowController alloc) init))
        (if SHOW_CONSOLE_AT_STARTUP ($console toggleConsole:self))))

;; install the delegate and keep a reference to it since the application won't retain it.
((NSApplication sharedApplication) setDelegate:(set $delegate ((ApplicationDelegate alloc) init)))

;; this makes the application window take focus when we've started it from the terminal (or with nuke)
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
