#!/bin/bash
#
# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
#  InstallSDL2
#  InstallRomFetcher
#  InstallEmulationStation
	case $RELEASE in
		stretch)
			# your code here
			# InstallOpenMediaVault # uncomment to get an OMV 4 image
			;;
		buster)
			# your code here
			;;
		bullseye)
			# your code here
			;;
		bionic)
			# your code here
			;;
		focal)
			# your code here
			;;
	esac
} # Main

InstallSDL2() {
  git clone https://github.com/libsdl-org/SDL /tmp/sdl
  cd /tmp/sdl

  patch -p1 <<EOF
diff --git a/src/joystick/SDL_gamecontrollerdb.h b/src/joystick/SDL_gamecontrollerdb.h
index aa9d35780..2698d5632 100644
--- a/src/joystick/SDL_gamecontrollerdb.h
+++ b/src/joystick/SDL_gamecontrollerdb.h
@@ -815,6 +815,7 @@ static const char *s_ControllerMappings [] =
     "050000006964726f69643a636f6e0000,idroid:con,a:b1,b:b2,back:b8,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b4,leftstick:b10,lefttrigger:b6,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b11,righttrigger:b7,rightx:a2,righty:a3,start:b9,x:b0,y:b3,",
     "03000000b50700001503000010010000,impact,a:b2,b:b3,back:b8,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b4,leftstick:b10,lefttrigger:b5,leftx:a0,lefty:a1,rightshoulder:b6,rightstick:b11,righttrigger:b7,rightx:a3,righty:a2,start:b9,x:b0,y:b1,",
     "030000009b2800000300000001010000,raphnet.net 4nes4snes v1.5,a:b0,b:b4,back:b2,leftshoulder:b6,leftx:a0,lefty:a1,rightshoulder:b7,start:b3,x:b1,y:b5,",
+    "00000000526574726f53746f6e653200,RetroStone2,a:b0,b:b1,x:b2,y:b3,dpdown:b11,dpleft:b12,dpright:b13,dpup:b10,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,start:b9,back:b8,leftx:a0,lefty:a1,platform:Linux",
 #endif
 #if defined(__ANDROID__)
     "05000000c82d000006500000ffff3f00,8BitDo M30 Gamepad,a:b0,b:b1,back:b4,guide:b17,leftshoulder:b9,lefttrigger:a5,leftx:a0,lefty:a1,rightshoulder:b10,righttrigger:a4,start:b6,x:b2,y:b3,hint:SDL_GAMECONTROLLER_USE_BUTTON_LABELS:=1,",
EOF

  ./configure --prefix=/usr && make && make install
}

InstallEmulationStation() {
  apt-get --yes --force-yes --allow-unauthenticated install libboost-system-dev libboost-filesystem-dev libboost-date-time-dev libboost-locale-dev libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev libasound2-dev cmake
  git clone https://github.com/Aloshi/EmulationStation /tmp/emulationstation
  cd /tmp/emulationstation
  patch -p1 <<EOF
#diff --git a/es-app/src/guis/GuiMenu.cpp b/es-app/src/guis/GuiMenu.cpp
#index 417d382..f47589b 100644
--- a/es-app/src/guis/GuiMenu.cpp
+++ b/es-app/src/guis/GuiMenu.cpp
@@ -1,231 +1,604 @@
-#include "EmulationStation.h"
 #include "guis/GuiMenu.h"
-#include "Window.h"
-#include "Sound.h"
-#include "Log.h"
-#include "Settings.h"
+
+#include "components/OptionListComponent.h"
+#include "components/SliderComponent.h"
+#include "components/SwitchComponent.h"
+#include "guis/GuiCollectionSystemsOptions.h"
+#include "guis/GuiDetectDevice.h"
+#include "guis/GuiGeneralScreensaverOptions.h"
 #include "guis/GuiMsgBox.h"
-#include "guis/GuiSettings.h"
 #include "guis/GuiScraperStart.h"
-#include "guis/GuiDetectDevice.h"
+#include "guis/GuiSettings.h"
+#include "views/UIModeController.h"
 #include "views/ViewController.h"
-
-#include "components/ButtonComponent.h"
-#include "components/SwitchComponent.h"
-#include "components/SliderComponent.h"
-#include "components/TextComponent.h"
-#include "components/OptionListComponent.h"
-#include "components/MenuComponent.h"
+#include "CollectionSystemManager.h"
+#include "EmulationStation.h"
+#include "Scripting.h"
+#include "SystemData.h"
 #include "VolumeControl.h"
-#include "scrapers/GamesDBScraper.h"
-#include "scrapers/TheArchiveScraper.h"
+#include <SDL_events.h>
+#include <algorithm>
+#include "platform.h"
+
+GuiMenu::GuiMenu(Window* window) : GuiComponent(window), mMenu(window, "ROPi 4.3 Menu"), mVersion(window)
+{
+	bool isFullUI = UIModeController::getInstance()->isUIModeFull();

-GuiMenu::GuiMenu(Window* window) : GuiComponent(window), mMenu(window, "MAIN MENU"), mVersion(window)
+	if (!(UIModeController::getInstance()->isUIModeKid() && Settings::getInstance()->getBool("hideQuitMenuOnKidUI")))
+		addEntry("QUIT", 0x777777FF, true, [this] {openQuitMenu(); });
+
+	if (isFullUI)
+		addEntry("CONFIGURE INPUT", 0x777777FF, true, [this] { openConfigInput(); });
+
+	if (isFullUI)
+		addEntry("SCRAPER", 0x777777FF, true, [this] { openScraperSettings(); });
+
+        if (isFullUI)
+		addEntry("SOUND SETTINGS", 0x777777FF, true, [this] { openSoundSettings(); });
+
+	if (isFullUI)
+		addEntry("UI SETTINGS", 0x777777FF, true, [this] { openUISettings(); });
+
+        if (isFullUI)
+                addEntry("LCD SETTINGS", 0x777777FF, true, [this] { openBrightnessSettings(); });
+
+	if (isFullUI)
+		addEntry("GAME COLLECTION SETTINGS", 0x777777FF, true, [this] { openCollectionSystemSettings(); });
+
+	if (isFullUI)
+		addEntry("OTHER SETTINGS", 0x777777FF, true, [this] { openOtherSettings(); });
+
+	addChild(&mMenu);
+	addVersionInfo();
+	setSize(mMenu.getSize());
+	setPosition((Renderer::getScreenWidth() - mSize.x()) / 2, Renderer::getScreenHeight() * 0.15f);
+}
+
+void GuiMenu::openScraperSettings()
 {
-	// MAIN MENU
+	auto s = new GuiSettings(mWindow, "SCRAPER");
+
+	// scrape from
+	auto scraper_list = std::make_shared< OptionListComponent< std::string > >(mWindow, "SCRAPE FROM", false);
+	std::vector<std::string> scrapers = getScraperList();

-	// SCRAPER >
-	// SOUND SETTINGS >
-	// UI SETTINGS >
-	// CONFIGURE INPUT >
-	// QUIT >
+	// Select either the first entry of the one read from the settings, just in case the scraper from settings has vanished.
+	for(auto it = scrapers.cbegin(); it != scrapers.cend(); it++)
+		scraper_list->add(*it, *it, *it == Settings::getInstance()->getString("Scraper"));

-	// [version]
+	s->addWithLabel("SCRAPE FROM", scraper_list);
+	s->addSaveFunc([scraper_list] { Settings::getInstance()->setString("Scraper", scraper_list->getSelected()); });

+	// scrape ratings
+	auto scrape_ratings = std::make_shared<SwitchComponent>(mWindow);
+	scrape_ratings->setState(Settings::getInstance()->getBool("ScrapeRatings"));
+	s->addWithLabel("SCRAPE RATINGS", scrape_ratings);
+	s->addSaveFunc([scrape_ratings] { Settings::getInstance()->setBool("ScrapeRatings", scrape_ratings->getState()); });
+
+	// scrape now
+	ComponentListRow row;
 	auto openScrapeNow = [this] { mWindow->pushGui(new GuiScraperStart(mWindow)); };
-	addEntry("SCRAPER", 0x777777FF, true,
-		[this, openScrapeNow] {
-			auto s = new GuiSettings(mWindow, "SCRAPER");
-
-			// scrape from
-			auto scraper_list = std::make_shared< OptionListComponent< std::string > >(mWindow, "SCRAPE FROM", false);
-			std::vector<std::string> scrapers = getScraperList();
-			for(auto it = scrapers.begin(); it != scrapers.end(); it++)
-				scraper_list->add(*it, *it, *it == Settings::getInstance()->getString("Scraper"));
-
-			s->addWithLabel("SCRAPE FROM", scraper_list);
-			s->addSaveFunc([scraper_list] { Settings::getInstance()->setString("Scraper", scraper_list->getSelected()); });
-
-			// scrape ratings
-			auto scrape_ratings = std::make_shared<SwitchComponent>(mWindow);
-			scrape_ratings->setState(Settings::getInstance()->getBool("ScrapeRatings"));
-			s->addWithLabel("SCRAPE RATINGS", scrape_ratings);
-			s->addSaveFunc([scrape_ratings] { Settings::getInstance()->setBool("ScrapeRatings", scrape_ratings->getState()); });
-
-			// scrape now
-			ComponentListRow row;
-			std::function<void()> openAndSave = openScrapeNow;
-			openAndSave = [s, openAndSave] { s->save(); openAndSave(); };
-			row.makeAcceptInputHandler(openAndSave);
-
-			auto scrape_now = std::make_shared<TextComponent>(mWindow, "SCRAPE NOW", Font::get(FONT_SIZE_MEDIUM), 0x777777FF);
-			auto bracket = makeArrow(mWindow);
-			row.addElement(scrape_now, true);
-			row.addElement(bracket, false);
-			s->addRow(row);
+	std::function<void()> openAndSave = openScrapeNow;
+	openAndSave = [s, openAndSave] { s->save(); openAndSave(); };
+	row.makeAcceptInputHandler(openAndSave);
+
+	auto scrape_now = std::make_shared<TextComponent>(mWindow, "SCRAPE NOW", Font::get(FONT_SIZE_MEDIUM), 0x777777FF);
+	auto bracket = makeArrow(mWindow);
+	row.addElement(scrape_now, true);
+	row.addElement(bracket, false);
+	s->addRow(row);
+
+	mWindow->pushGui(s);
+}
+
+int getBrightness(){
+        int brightness;
+
+        FILE *fp = fopen("/sys/class/backlight/backlight/actual_brightness", "r");
+        if (fp!=NULL) {
+                fscanf(fp, "%d", &brightness);
+                fclose (fp);
+        }
+        return brightness;
+}
+
+void setBrightness(int brightness){
+        if (brightness>100)     { brightness = 100;}
+        if (brightness<0)   { brightness = 0;}
+
+        FILE *fp = fopen("/sys/class/backlight/backlight/brightness", "w");
+        if (fp!=NULL) {
+                fprintf(fp, "%d", brightness);
+                fclose(fp);
+        }
+        return;
+}
+
+void GuiMenu::openBrightnessSettings()
+{
+        auto s = new GuiSettings(mWindow, "LCD SETTINGS");
+
+        // brightness
+        auto brightness = std::make_shared<SliderComponent>(mWindow, 10.f, 100.f, 1.f, "%");
+        brightness->setValue((float)getBrightness());
+        s->addWithLabel("LCD BRIGHTNESS", brightness);
+        s->addSaveFunc([brightness] { setBrightness((int)Math::round(brightness->getValue())); });
+
+        mWindow->pushGui(s);
+
+}
+
+void GuiMenu::openSoundSettings()
+{
+	auto s = new GuiSettings(mWindow, "SOUND SETTINGS");
+
+	// volume
+	auto volume = std::make_shared<SliderComponent>(mWindow, 0.f, 100.f, 1.f, "%");
+	volume->setValue((float)VolumeControl::getInstance()->getVolume());
+	s->addWithLabel("SYSTEM VOLUME", volume);
+	s->addSaveFunc([volume] { VolumeControl::getInstance()->setVolume((int)Math::round(volume->getValue())); });
+
+	if (UIModeController::getInstance()->isUIModeFull())
+	{
+#if defined(__linux__)
+		// audio card
+		auto audio_card = std::make_shared< OptionListComponent<std::string> >(mWindow, "AUDIO CARD", false);
+		std::vector<std::string> audio_cards;
+	#ifdef _RPI_
+		// RPi Specific  Audio Cards
+		audio_cards.push_back("local");
+		audio_cards.push_back("hdmi");
+		audio_cards.push_back("both");
+	#endif
+		audio_cards.push_back("default");
+		audio_cards.push_back("sysdefault");
+		audio_cards.push_back("dmix");
+		audio_cards.push_back("hw");
+		audio_cards.push_back("plughw");
+		audio_cards.push_back("null");
+		if (Settings::getInstance()->getString("AudioCard") != "") {
+			if(std::find(audio_cards.begin(), audio_cards.end(), Settings::getInstance()->getString("AudioCard")) == audio_cards.end()) {
+				audio_cards.push_back(Settings::getInstance()->getString("AudioCard"));
+			}
+		}
+		for(auto ac = audio_cards.cbegin(); ac != audio_cards.cend(); ac++)
+			audio_card->add(*ac, *ac, Settings::getInstance()->getString("AudioCard") == *ac);
+		s->addWithLabel("AUDIO CARD", audio_card);
+		s->addSaveFunc([audio_card] {
+			Settings::getInstance()->setString("AudioCard", audio_card->getSelected());
+			VolumeControl::getInstance()->deinit();
+			VolumeControl::getInstance()->init();
+		});
+
+		// volume control device
+		auto vol_dev = std::make_shared< OptionListComponent<std::string> >(mWindow, "AUDIO DEVICE", false);
+		std::vector<std::string> transitions;
+		transitions.push_back("PCM");
+		transitions.push_back("Speaker");
+		transitions.push_back("Master");
+		transitions.push_back("Digital");
+		transitions.push_back("Analogue");
+		if (Settings::getInstance()->getString("AudioDevice") != "") {
+			if(std::find(transitions.begin(), transitions.end(), Settings::getInstance()->getString("AudioDevice")) == transitions.end()) {
+				transitions.push_back(Settings::getInstance()->getString("AudioDevice"));
+			}
+		}
+		for(auto it = transitions.cbegin(); it != transitions.cend(); it++)
+			vol_dev->add(*it, *it, Settings::getInstance()->getString("AudioDevice") == *it);
+		s->addWithLabel("AUDIO DEVICE", vol_dev);
+		s->addSaveFunc([vol_dev] {
+			Settings::getInstance()->setString("AudioDevice", vol_dev->getSelected());
+			VolumeControl::getInstance()->deinit();
+			VolumeControl::getInstance()->init();
+		});
+#endif
+
+		// disable sounds
+		auto sounds_enabled = std::make_shared<SwitchComponent>(mWindow);
+		sounds_enabled->setState(Settings::getInstance()->getBool("EnableSounds"));
+		s->addWithLabel("ENABLE NAVIGATION SOUNDS", sounds_enabled);
+		s->addSaveFunc([sounds_enabled] {
+			if (sounds_enabled->getState()
+				&& !Settings::getInstance()->getBool("EnableSounds")
+				&& PowerSaver::getMode() == PowerSaver::INSTANT)
+			{
+				Settings::getInstance()->setString("PowerSaverMode", "default");
+				PowerSaver::init();
+			}
+			Settings::getInstance()->setBool("EnableSounds", sounds_enabled->getState());
+		});
+
+		auto video_audio = std::make_shared<SwitchComponent>(mWindow);
+		video_audio->setState(Settings::getInstance()->getBool("VideoAudio"));
+		s->addWithLabel("ENABLE VIDEO AUDIO", video_audio);
+		s->addSaveFunc([video_audio] { Settings::getInstance()->setBool("VideoAudio", video_audio->getState()); });
+
+#ifdef _RPI_
+		// OMX player Audio Device
+		auto omx_audio_dev = std::make_shared< OptionListComponent<std::string> >(mWindow, "OMX PLAYER AUDIO DEVICE", false);
+		std::vector<std::string> omx_cards;
+		// RPi Specific  Audio Cards
+		omx_cards.push_back("local");
+		omx_cards.push_back("hdmi");
+		omx_cards.push_back("both");
+		omx_cards.push_back("alsa:hw:0,0");
+		omx_cards.push_back("alsa:hw:1,0");
+		if (Settings::getInstance()->getString("OMXAudioDev") != "") {
+			if (std::find(omx_cards.begin(), omx_cards.end(), Settings::getInstance()->getString("OMXAudioDev")) == omx_cards.end()) {
+				omx_cards.push_back(Settings::getInstance()->getString("OMXAudioDev"));
+			}
+		}
+		for (auto it = omx_cards.cbegin(); it != omx_cards.cend(); it++)
+			omx_audio_dev->add(*it, *it, Settings::getInstance()->getString("OMXAudioDev") == *it);
+		s->addWithLabel("OMX PLAYER AUDIO DEVICE", omx_audio_dev);
+		s->addSaveFunc([omx_audio_dev] {
+			if (Settings::getInstance()->getString("OMXAudioDev") != omx_audio_dev->getSelected())
+				Settings::getInstance()->setString("OMXAudioDev", omx_audio_dev->getSelected());
+		});
+#endif
+	}
+
+	mWindow->pushGui(s);
+
+}
+
+void GuiMenu::openUISettings()
+{
+	auto s = new GuiSettings(mWindow, "UI SETTINGS");
+
+	//UI mode
+	auto UImodeSelection = std::make_shared< OptionListComponent<std::string> >(mWindow, "UI MODE", false);
+	std::vector<std::string> UImodes = UIModeController::getInstance()->getUIModes();
+	for (auto it = UImodes.cbegin(); it != UImodes.cend(); it++)
+		UImodeSelection->add(*it, *it, Settings::getInstance()->getString("UIMode") == *it);
+	s->addWithLabel("UI MODE", UImodeSelection);
+	Window* window = mWindow;
+	s->addSaveFunc([ UImodeSelection, window]
+	{
+		std::string selectedMode = UImodeSelection->getSelected();
+		if (selectedMode != "Full")
+		{
+			std::string msg = "You are changing the UI to a restricted mode:\n" + selectedMode + "\n";
+			msg += "This will hide most menu-options to prevent changes to the system.\n";
+			msg += "To unlock and return to the full UI, enter this code: \n";
+			msg += "\"" + UIModeController::getInstance()->getFormattedPassKeyStr() + "\"\n\n";
+			msg += "Do you want to proceed?";
+			window->pushGui(new GuiMsgBox(window, msg,
+				"YES", [selectedMode] {
+					LOG(LogDebug) << "Setting UI mode to " << selectedMode;
+					Settings::getInstance()->setString("UIMode", selectedMode);
+					Settings::getInstance()->saveFile();
+			}, "NO",nullptr));
+		}
+	});

-			mWindow->pushGui(s);
+	// screensaver
+	ComponentListRow screensaver_row;
+	screensaver_row.elements.clear();
+	screensaver_row.addElement(std::make_shared<TextComponent>(mWindow, "SCREENSAVER SETTINGS", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
+	screensaver_row.addElement(makeArrow(mWindow), false);
+	screensaver_row.makeAcceptInputHandler(std::bind(&GuiMenu::openScreensaverOptions, this));
+	s->addRow(screensaver_row);
+
+	// quick system select (left/right in game list view)
+	auto quick_sys_select = std::make_shared<SwitchComponent>(mWindow);
+	quick_sys_select->setState(Settings::getInstance()->getBool("QuickSystemSelect"));
+	s->addWithLabel("QUICK SYSTEM SELECT", quick_sys_select);
+	s->addSaveFunc([quick_sys_select] { Settings::getInstance()->setBool("QuickSystemSelect", quick_sys_select->getState()); });
+
+	// carousel transition option
+	auto move_carousel = std::make_shared<SwitchComponent>(mWindow);
+	move_carousel->setState(Settings::getInstance()->getBool("MoveCarousel"));
+	s->addWithLabel("CAROUSEL TRANSITIONS", move_carousel);
+	s->addSaveFunc([move_carousel] {
+		if (move_carousel->getState()
+			&& !Settings::getInstance()->getBool("MoveCarousel")
+			&& PowerSaver::getMode() == PowerSaver::INSTANT)
+		{
+			Settings::getInstance()->setString("PowerSaverMode", "default");
+			PowerSaver::init();
+		}
+		Settings::getInstance()->setBool("MoveCarousel", move_carousel->getState());
 	});

-	addEntry("SOUND SETTINGS", 0x777777FF, true,
-		[this] {
-			auto s = new GuiSettings(mWindow, "SOUND SETTINGS");
-
-			// volume
-			auto volume = std::make_shared<SliderComponent>(mWindow, 0.f, 100.f, 1.f, "%");
-			volume->setValue((float)VolumeControl::getInstance()->getVolume());
-			s->addWithLabel("SYSTEM VOLUME", volume);
-			s->addSaveFunc([volume] { VolumeControl::getInstance()->setVolume((int)round(volume->getValue())); });
-
-			// disable sounds
-			auto sounds_enabled = std::make_shared<SwitchComponent>(mWindow);
-			sounds_enabled->setState(Settings::getInstance()->getBool("EnableSounds"));
-			s->addWithLabel("ENABLE SOUNDS", sounds_enabled);
-			s->addSaveFunc([sounds_enabled] { Settings::getInstance()->setBool("EnableSounds", sounds_enabled->getState()); });
-
-			mWindow->pushGui(s);
+	// transition style
+	auto transition_style = std::make_shared< OptionListComponent<std::string> >(mWindow, "TRANSITION STYLE", false);
+	std::vector<std::string> transitions;
+	transitions.push_back("fade");
+	transitions.push_back("slide");
+	transitions.push_back("instant");
+	for(auto it = transitions.cbegin(); it != transitions.cend(); it++)
+		transition_style->add(*it, *it, Settings::getInstance()->getString("TransitionStyle") == *it);
+	s->addWithLabel("TRANSITION STYLE", transition_style);
+	s->addSaveFunc([transition_style] {
+		if (Settings::getInstance()->getString("TransitionStyle") == "instant"
+			&& transition_style->getSelected() != "instant"
+			&& PowerSaver::getMode() == PowerSaver::INSTANT)
+		{
+			Settings::getInstance()->setString("PowerSaverMode", "default");
+			PowerSaver::init();
+		}
+		Settings::getInstance()->setString("TransitionStyle", transition_style->getSelected());
 	});

-	addEntry("UI SETTINGS", 0x777777FF, true,
-		[this] {
-			auto s = new GuiSettings(mWindow, "UI SETTINGS");
-
-			// screensaver time
-			auto screensaver_time = std::make_shared<SliderComponent>(mWindow, 0.f, 30.f, 1.f, "m");
-			screensaver_time->setValue((float)(Settings::getInstance()->getInt("ScreenSaverTime") / (1000 * 60)));
-			s->addWithLabel("SCREENSAVER AFTER", screensaver_time);
-			s->addSaveFunc([screensaver_time] { Settings::getInstance()->setInt("ScreenSaverTime", (int)round(screensaver_time->getValue()) * (1000 * 60)); });
-
-			// screensaver behavior
-			auto screensaver_behavior = std::make_shared< OptionListComponent<std::string> >(mWindow, "TRANSITION STYLE", false);
-			std::vector<std::string> screensavers;
-			screensavers.push_back("dim");
-			screensavers.push_back("black");
-			for(auto it = screensavers.begin(); it != screensavers.end(); it++)
-				screensaver_behavior->add(*it, *it, Settings::getInstance()->getString("ScreenSaverBehavior") == *it);
-			s->addWithLabel("SCREENSAVER BEHAVIOR", screensaver_behavior);
-			s->addSaveFunc([screensaver_behavior] { Settings::getInstance()->setString("ScreenSaverBehavior", screensaver_behavior->getSelected()); });
-
-			// framerate
-			auto framerate = std::make_shared<SwitchComponent>(mWindow);
-			framerate->setState(Settings::getInstance()->getBool("DrawFramerate"));
-			s->addWithLabel("SHOW FRAMERATE", framerate);
-			s->addSaveFunc([framerate] { Settings::getInstance()->setBool("DrawFramerate", framerate->getState()); });
-
-			// show help
-			auto show_help = std::make_shared<SwitchComponent>(mWindow);
-			show_help->setState(Settings::getInstance()->getBool("ShowHelpPrompts"));
-			s->addWithLabel("ON-SCREEN HELP", show_help);
-			s->addSaveFunc([show_help] { Settings::getInstance()->setBool("ShowHelpPrompts", show_help->getState()); });
-
-			// quick system select (left/right in game list view)
-			auto quick_sys_select = std::make_shared<SwitchComponent>(mWindow);
-			quick_sys_select->setState(Settings::getInstance()->getBool("QuickSystemSelect"));
-			s->addWithLabel("QUICK SYSTEM SELECT", quick_sys_select);
-			s->addSaveFunc([quick_sys_select] { Settings::getInstance()->setBool("QuickSystemSelect", quick_sys_select->getState()); });
-
-			// transition style
-			auto transition_style = std::make_shared< OptionListComponent<std::string> >(mWindow, "TRANSITION STYLE", false);
-			std::vector<std::string> transitions;
-			transitions.push_back("fade");
-			transitions.push_back("slide");
-			for(auto it = transitions.begin(); it != transitions.end(); it++)
-				transition_style->add(*it, *it, Settings::getInstance()->getString("TransitionStyle") == *it);
-			s->addWithLabel("TRANSITION STYLE", transition_style);
-			s->addSaveFunc([transition_style] { Settings::getInstance()->setString("TransitionStyle", transition_style->getSelected()); });
-
-			// theme set
-			auto themeSets = ThemeData::getThemeSets();
-
-			if(!themeSets.empty())
+	// theme set
+	auto themeSets = ThemeData::getThemeSets();
+
+	if(!themeSets.empty())
+	{
+		std::map<std::string, ThemeSet>::const_iterator selectedSet = themeSets.find(Settings::getInstance()->getString("ThemeSet"));
+		if(selectedSet == themeSets.cend())
+			selectedSet = themeSets.cbegin();
+
+		auto theme_set = std::make_shared< OptionListComponent<std::string> >(mWindow, "THEME SET", false);
+		for(auto it = themeSets.cbegin(); it != themeSets.cend(); it++)
+			theme_set->add(it->first, it->first, it == selectedSet);
+		s->addWithLabel("THEME SET", theme_set);
+
+		Window* window = mWindow;
+		s->addSaveFunc([window, theme_set]
+		{
+			bool needReload = false;
+			std::string oldTheme = Settings::getInstance()->getString("ThemeSet");
+			if(oldTheme != theme_set->getSelected())
+				needReload = true;
+
+			Settings::getInstance()->setString("ThemeSet", theme_set->getSelected());
+
+			if(needReload)
 			{
-				auto selectedSet = themeSets.find(Settings::getInstance()->getString("ThemeSet"));
-				if(selectedSet == themeSets.end())
-					selectedSet = themeSets.begin();
-
-				auto theme_set = std::make_shared< OptionListComponent<std::string> >(mWindow, "THEME SET", false);
-				for(auto it = themeSets.begin(); it != themeSets.end(); it++)
-					theme_set->add(it->first, it->first, it == selectedSet);
-				s->addWithLabel("THEME SET", theme_set);
-
-				Window* window = mWindow;
-				s->addSaveFunc([window, theme_set]
-				{
-					bool needReload = false;
-					if(Settings::getInstance()->getString("ThemeSet") != theme_set->getSelected())
-						needReload = true;
-
-					Settings::getInstance()->setString("ThemeSet", theme_set->getSelected());
-
-					if(needReload)
-						ViewController::get()->reloadAll(); // TODO - replace this with some sort of signal-based implementation
-				});
+				Scripting::fireEvent("theme-changed", theme_set->getSelected(), oldTheme);
+				CollectionSystemManager::get()->updateSystemsList();
+				ViewController::get()->goToStart();
+				ViewController::get()->reloadAll(); // TODO - replace this with some sort of signal-based implementation
 			}
+		});
+	}
+
+	// GameList view style
+	auto gamelist_style = std::make_shared< OptionListComponent<std::string> >(mWindow, "GAMELIST VIEW STYLE", false);
+	std::vector<std::string> styles;
+	styles.push_back("automatic");
+	styles.push_back("basic");
+	styles.push_back("detailed");
+	styles.push_back("video");
+	styles.push_back("grid");
+
+	for (auto it = styles.cbegin(); it != styles.cend(); it++)
+		gamelist_style->add(*it, *it, Settings::getInstance()->getString("GamelistViewStyle") == *it);
+	s->addWithLabel("GAMELIST VIEW STYLE", gamelist_style);
+	s->addSaveFunc([gamelist_style] {
+		bool needReload = false;
+		if (Settings::getInstance()->getString("GamelistViewStyle") != gamelist_style->getSelected())
+			needReload = true;
+		Settings::getInstance()->setString("GamelistViewStyle", gamelist_style->getSelected());
+		if (needReload)
+			ViewController::get()->reloadAll();
+	});

-			mWindow->pushGui(s);
+	// Optionally start in selected system
+	auto systemfocus_list = std::make_shared< OptionListComponent<std::string> >(mWindow, "START ON SYSTEM", false);
+	systemfocus_list->add("NONE", "", Settings::getInstance()->getString("StartupSystem") == "");
+	for (auto it = SystemData::sSystemVector.cbegin(); it != SystemData::sSystemVector.cend(); it++)
+	{
+		if ("retropie" != (*it)->getName())
+		{
+			systemfocus_list->add((*it)->getName(), (*it)->getName(), Settings::getInstance()->getString("StartupSystem") == (*it)->getName());
+		}
+	}
+	s->addWithLabel("START ON SYSTEM", systemfocus_list);
+	s->addSaveFunc([systemfocus_list] {
+		Settings::getInstance()->setString("StartupSystem", systemfocus_list->getSelected());
 	});

-	addEntry("CONFIGURE INPUT", 0x777777FF, true,
-		[this] {
-			mWindow->pushGui(new GuiDetectDevice(mWindow, false, nullptr));
+	// show help
+	auto show_help = std::make_shared<SwitchComponent>(mWindow);
+	show_help->setState(Settings::getInstance()->getBool("ShowHelpPrompts"));
+	s->addWithLabel("ON-SCREEN HELP", show_help);
+	s->addSaveFunc([show_help] { Settings::getInstance()->setBool("ShowHelpPrompts", show_help->getState()); });
+
+	// enable filters (ForceDisableFilters)
+	auto enable_filter = std::make_shared<SwitchComponent>(mWindow);
+	enable_filter->setState(!Settings::getInstance()->getBool("ForceDisableFilters"));
+	s->addWithLabel("ENABLE FILTERS", enable_filter);
+	s->addSaveFunc([enable_filter] {
+		bool filter_is_enabled = !Settings::getInstance()->getBool("ForceDisableFilters");
+		Settings::getInstance()->setBool("ForceDisableFilters", !enable_filter->getState());
+		if (enable_filter->getState() != filter_is_enabled) ViewController::get()->ReloadAndGoToStart();
 	});

-	addEntry("QUIT", 0x777777FF, true,
-		[this] {
-			auto s = new GuiSettings(mWindow, "QUIT");
-
-			Window* window = mWindow;
+	mWindow->pushGui(s);

-			ComponentListRow row;
-			row.makeAcceptInputHandler([window] {
-				window->pushGui(new GuiMsgBox(window, "REALLY RESTART?", "YES",
-				[] {
-					if(runRestartCommand() != 0)
-						LOG(LogWarning) << "Restart terminated with non-zero result!";
-				}, "NO", nullptr));
-			});
-			row.addElement(std::make_shared<TextComponent>(window, "RESTART SYSTEM", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
-			s->addRow(row);
+}
+
+void GuiMenu::openOtherSettings()
+{
+	auto s = new GuiSettings(mWindow, "OTHER SETTINGS");
+
+	// maximum vram
+	auto max_vram = std::make_shared<SliderComponent>(mWindow, 0.f, 1000.f, 10.f, "Mb");
+	max_vram->setValue((float)(Settings::getInstance()->getInt("MaxVRAM")));
+	s->addWithLabel("VRAM LIMIT", max_vram);
+	s->addSaveFunc([max_vram] { Settings::getInstance()->setInt("MaxVRAM", (int)Math::round(max_vram->getValue())); });
+
+	// power saver
+	auto power_saver = std::make_shared< OptionListComponent<std::string> >(mWindow, "POWER SAVER MODES", false);
+	std::vector<std::string> modes;
+	modes.push_back("disabled");
+	modes.push_back("default");
+	modes.push_back("enhanced");
+	modes.push_back("instant");
+	for (auto it = modes.cbegin(); it != modes.cend(); it++)
+		power_saver->add(*it, *it, Settings::getInstance()->getString("PowerSaverMode") == *it);
+	s->addWithLabel("POWER SAVER MODES", power_saver);
+	s->addSaveFunc([this, power_saver] {
+		if (Settings::getInstance()->getString("PowerSaverMode") != "instant" && power_saver->getSelected() == "instant") {
+			Settings::getInstance()->setString("TransitionStyle", "instant");
+			Settings::getInstance()->setBool("MoveCarousel", false);
+			Settings::getInstance()->setBool("EnableSounds", false);
+		}
+		Settings::getInstance()->setString("PowerSaverMode", power_saver->getSelected());
+		PowerSaver::init();
+	});
+
+	// gamelists
+	auto save_gamelists = std::make_shared<SwitchComponent>(mWindow);
+	save_gamelists->setState(Settings::getInstance()->getBool("SaveGamelistsOnExit"));
+	s->addWithLabel("SAVE METADATA ON EXIT", save_gamelists);
+	s->addSaveFunc([save_gamelists] { Settings::getInstance()->setBool("SaveGamelistsOnExit", save_gamelists->getState()); });
+
+	auto parse_gamelists = std::make_shared<SwitchComponent>(mWindow);
+	parse_gamelists->setState(Settings::getInstance()->getBool("ParseGamelistOnly"));
+	s->addWithLabel("PARSE GAMESLISTS ONLY", parse_gamelists);
+	s->addSaveFunc([parse_gamelists] { Settings::getInstance()->setBool("ParseGamelistOnly", parse_gamelists->getState()); });
+
+	auto local_art = std::make_shared<SwitchComponent>(mWindow);
+	local_art->setState(Settings::getInstance()->getBool("LocalArt"));
+	s->addWithLabel("SEARCH FOR LOCAL ART", local_art);
+	s->addSaveFunc([local_art] { Settings::getInstance()->setBool("LocalArt", local_art->getState()); });
+
+	// hidden files
+	auto hidden_files = std::make_shared<SwitchComponent>(mWindow);
+	hidden_files->setState(Settings::getInstance()->getBool("ShowHiddenFiles"));
+	s->addWithLabel("SHOW HIDDEN FILES", hidden_files);
+	s->addSaveFunc([hidden_files] { Settings::getInstance()->setBool("ShowHiddenFiles", hidden_files->getState()); });
+
+#ifdef _RPI_
+	// Video Player - VideoOmxPlayer
+	auto omx_player = std::make_shared<SwitchComponent>(mWindow);
+	omx_player->setState(Settings::getInstance()->getBool("VideoOmxPlayer"));
+	s->addWithLabel("USE OMX PLAYER (HW ACCELERATED)", omx_player);
+	s->addSaveFunc([omx_player]
+	{
+		// need to reload all views to re-create the right video components
+		bool needReload = false;
+		if(Settings::getInstance()->getBool("VideoOmxPlayer") != omx_player->getState())
+			needReload = true;
+
+		Settings::getInstance()->setBool("VideoOmxPlayer", omx_player->getState());
+
+		if(needReload)
+			ViewController::get()->reloadAll();
+	});
+
+#endif
+
+	// framerate
+	auto framerate = std::make_shared<SwitchComponent>(mWindow);
+	framerate->setState(Settings::getInstance()->getBool("DrawFramerate"));
+	s->addWithLabel("SHOW FRAMERATE", framerate);
+	s->addSaveFunc([framerate] { Settings::getInstance()->setBool("DrawFramerate", framerate->getState()); });
+
+
+	mWindow->pushGui(s);
+
+}
+
+void GuiMenu::openConfigInput()
+{
+	Window* window = mWindow;
+	window->pushGui(new GuiMsgBox(window, "ARE YOU SURE YOU WANT TO CONFIGURE INPUT?", "YES",
+		[window] {
+		window->pushGui(new GuiDetectDevice(window, false, nullptr));
+	}, "NO", nullptr)
+	);
+
+}

+void GuiMenu::openDesktop()
+{
+	Window* window = mWindow;
+	window->pushGui(new GuiMsgBox(window, "ARE YOU SURE YOU WANT TO LAUNCH DESKTOP?", "YES",
+		[window] {
+                         if(system("ArmbianDesktop") !=0);
+                         //if(system("startx 2> /dev/null") !=0);
+	}, "NO", nullptr)
+	);
+
+}
+
+void GuiMenu::openQuitMenu()
+{
+	auto s = new GuiSettings(mWindow, "QUIT");
+
+	Window* window = mWindow;
+
+	ComponentListRow row;
+	if (UIModeController::getInstance()->isUIModeFull())
+	{
+		row.makeAcceptInputHandler([window] {
+			window->pushGui(new GuiMsgBox(window, "REALLY RESTART?", "YES",
+				[] {
+				Scripting::fireEvent("quit");
+				if(quitES(QuitMode::RESTART) != 0)
+					LOG(LogWarning) << "Restart terminated with non-zero result!";
+			}, "NO", nullptr));
+		});
+		row.addElement(std::make_shared<TextComponent>(window, "RESTART EMULATIONSTATION", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
+		s->addRow(row);
+
+
+
+		if(Settings::getInstance()->getBool("ShowExit"))
+		{
 			row.elements.clear();
 			row.makeAcceptInputHandler([window] {
-				window->pushGui(new GuiMsgBox(window, "REALLY SHUTDOWN?", "YES",
-				[] {
-					if(runShutdownCommand() != 0)
-						LOG(LogWarning) << "Shutdown terminated with non-zero result!";
+				window->pushGui(new GuiMsgBox(window, "REALLY QUIT?", "YES",
+					[] {
+					Scripting::fireEvent("quit");
+					quitES();
 				}, "NO", nullptr));
 			});
-			row.addElement(std::make_shared<TextComponent>(window, "SHUTDOWN SYSTEM", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
+			row.addElement(std::make_shared<TextComponent>(window, "QUIT EMULATIONSTATION", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
 			s->addRow(row);
+		}
+	}
+	row.elements.clear();
+	row.makeAcceptInputHandler([window] {
+		window->pushGui(new GuiMsgBox(window, "REALLY RESTART?", "YES",
+			[] {
+			Scripting::fireEvent("quit", "reboot");
+			Scripting::fireEvent("reboot");
+			if (quitES(QuitMode::REBOOT) != 0)
+				LOG(LogWarning) << "Restart terminated with non-zero result!";
+		}, "NO", nullptr));
+	});
+	row.addElement(std::make_shared<TextComponent>(window, "RESTART SYSTEM", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
+	s->addRow(row);
+
+	row.elements.clear();
+	row.makeAcceptInputHandler([window] {
+		window->pushGui(new GuiMsgBox(window, "REALLY SHUTDOWN?", "YES",
+			[] {
+			Scripting::fireEvent("quit", "shutdown");
+			Scripting::fireEvent("shutdown");
+			if (quitES(QuitMode::SHUTDOWN) != 0)
+				LOG(LogWarning) << "Shutdown terminated with non-zero result!";
+		}, "NO", nullptr));
+	});
+	row.addElement(std::make_shared<TextComponent>(window, "SHUTDOWN SYSTEM", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
+	s->addRow(row);

-			if(Settings::getInstance()->getBool("ShowExit"))
-			{
-				row.elements.clear();
-				row.makeAcceptInputHandler([window] {
-					window->pushGui(new GuiMsgBox(window, "REALLY QUIT?", "YES",
-					[] {
-						SDL_Event ev;
-						ev.type = SDL_QUIT;
-						SDL_PushEvent(&ev);
-					}, "NO", nullptr));
-				});
-				row.addElement(std::make_shared<TextComponent>(window, "QUIT EMULATIONSTATION", Font::get(FONT_SIZE_MEDIUM), 0x777777FF), true);
-				s->addRow(row);
-			}
+	mWindow->pushGui(s);
+}

-			mWindow->pushGui(s);
-	});
+void GuiMenu::addVersionInfo()
+{
+	std::string  buildDate = (Settings::getInstance()->getBool("Debug") ? std::string( "   (" + Utils::String::toUpper(PROGRAM_BUILT_STRING) + ")") : (""));

 	mVersion.setFont(Font::get(FONT_SIZE_SMALL));
-	mVersion.setColor(0xC6C6C6FF);
-	mVersion.setText("EMULATIONSTATION V" + strToUpper(PROGRAM_VERSION_STRING));
-	mVersion.setAlignment(ALIGN_CENTER);
-
-	addChild(&mMenu);
+	mVersion.setColor(0x5E5E5EFF);
+	mVersion.setText("Brought you by RetrOrangePi");
+	mVersion.setHorizontalAlignment(ALIGN_CENTER);
 	addChild(&mVersion);
+}

-	setSize(mMenu.getSize());
-	setPosition((Renderer::getScreenWidth() - mSize.x()) / 2, Renderer::getScreenHeight() * 0.15f);
+void GuiMenu::openScreensaverOptions() {
+	mWindow->pushGui(new GuiGeneralScreensaverOptions(mWindow, "SCREENSAVER SETTINGS"));
+}
+
+void GuiMenu::openCollectionSystemSettings() {
+	mWindow->pushGui(new GuiCollectionSystemsOptions(mWindow));
 }

 void GuiMenu::onSizeChanged()
@@ -237,7 +610,7 @@ void GuiMenu::onSizeChanged()
 void GuiMenu::addEntry(const char* name, unsigned int color, bool add_arrow, const std::function<void()>& func)
 {
 	std::shared_ptr<Font> font = Font::get(FONT_SIZE_MEDIUM);
-
+
 	// populate the list
 	ComponentListRow row;
 	row.addElement(std::make_shared<TextComponent>(mWindow, name, font, color), true);
@@ -247,7 +620,7 @@ void GuiMenu::addEntry(const char* name, unsigned int color, bool add_arrow, con
 		std::shared_ptr<ImageComponent> bracket = makeArrow(mWindow);
 		row.addElement(bracket, false);
 	}
-
+
 	row.makeAcceptInputHandler(func);

 	mMenu.addRow(row);
@@ -267,6 +640,13 @@ bool GuiMenu::input(InputConfig* config, Input input)
 	return false;
 }

+HelpStyle GuiMenu::getHelpStyle()
+{
+	HelpStyle style = HelpStyle();
+	style.applyTheme(ViewController::get()->getState().getSystem()->getTheme(), "system");
+	return style;
+}
+
 std::vector<HelpPrompt> GuiMenu::getHelpPrompts()
 {
 	std::vector<HelpPrompt> prompts;
diff --git a/es-app/src/guis/GuiMenu.h b/es-app/src/guis/GuiMenu.h
index eff9ebd..507a257 100644
--- a/es-app/src/guis/GuiMenu.h
+++ b/es-app/src/guis/GuiMenu.h
@@ -1,8 +1,9 @@
 #pragma once
+#ifndef ES_APP_GUIS_GUI_MENU_H
+#define ES_APP_GUIS_GUI_MENU_H

-#include "GuiComponent.h"
 #include "components/MenuComponent.h"
-#include <functional>
+#include "GuiComponent.h"

 class GuiMenu : public GuiComponent
 {
@@ -12,10 +13,24 @@ public:
 	bool input(InputConfig* config, Input input) override;
 	void onSizeChanged() override;
 	std::vector<HelpPrompt> getHelpPrompts() override;
+	HelpStyle getHelpStyle() override;

 private:
 	void addEntry(const char* name, unsigned int color, bool add_arrow, const std::function<void()>& func);
+	void addVersionInfo();
+	void openCollectionSystemSettings();
+	void openDesktop();
+	void openConfigInput();
+        void openBrightnessSettings();
+	void openOtherSettings();
+	void openQuitMenu();
+	void openScraperSettings();
+	void openScreensaverOptions();
+	void openSoundSettings();
+	void openUISettings();

 	MenuComponent mMenu;
 	TextComponent mVersion;
 };
+
+#endif // ES_APP_GUIS_GUI_MENU_H
EOF
  mkdir build
  cd build
  cmake ..
  make -j2
  make install
}

InstallRomFetcher() {
  apt-get --yes --force-yes --allow-unauthenticated install libcurl4-openssl-dev libsqlite3-dev libcurl4-openssl-dev cmake
  mkdir /tmp/romfetcher
  cd /tmp/romfetcher
  (git clone https://github.com/maximilianvoss/csafestring.git && cd csafestring && cmake -G "Unix Makefiles" && make && sudo make install)
  (git clone https://github.com/maximilianvoss/casserts.git && cd casserts && cmake -G "Unix Makefiles" && make && sudo make install)
  (git clone https://github.com/maximilianvoss/clogger.git && cd clogger && cmake -G "Unix Makefiles" && make && sudo make install)
  (git clone https://github.com/maximilianvoss/chttp.git && cd chttp && cmake -G "Unix Makefiles" && make && sudo make install)
  (git clone https://github.com/maximilianvoss/acll.git && cd acll && cmake -G "Unix Makefiles" && make && sudo make install)
  (git clone https://github.com/lexbor/lexbor.git && cd lexbor && cmake -G "Unix Makefiles" && make && sudo make install)
  (git clone https://github.com/maximilianvoss/romlibrary.git; cd romlibrary; cmake -G "Unix Makefiles"; make; sudo make install)
  (git clone https://github.com/maximilianvoss/romfetcher.git; cd romfetcher; cmake -G "Unix Makefiles"; make; sudo make install)
  cd /
  rm -rf /tmp/romfetcher
}

InstallOpenMediaVault() {
	# use this routine to create a Debian based fully functional OpenMediaVault
	# image (OMV 3 on Jessie, OMV 4 with Stretch). Use of mainline kernel highly
	# recommended!
	#
	# Please note that this variant changes Armbian default security
	# policies since you end up with root password 'openmediavault' which
	# you have to change yourself later. SSH login as root has to be enabled
	# through OMV web UI first
	#
	# This routine is based on idea/code courtesy Benny Stark. For fixes,
	# discussion and feature requests please refer to
	# https://forum.armbian.com/index.php?/topic/2644-openmediavault-3x-customize-imagesh/

	echo root:openmediavault | chpasswd
	rm /root/.not_logged_in_yet
	. /etc/default/cpufrequtils
	export LANG=C LC_ALL="en_US.UTF-8"
	export DEBIAN_FRONTEND=noninteractive
	export APT_LISTCHANGES_FRONTEND=none

	case ${RELEASE} in
		jessie)
			OMV_Name="erasmus"
			OMV_EXTRAS_URL="https://github.com/OpenMediaVault-Plugin-Developers/packages/raw/master/openmediavault-omvextrasorg_latest_all3.deb"
			;;
		stretch)
			OMV_Name="arrakis"
			OMV_EXTRAS_URL="https://github.com/OpenMediaVault-Plugin-Developers/packages/raw/master/openmediavault-omvextrasorg_latest_all4.deb"
			;;
	esac

	# Add OMV source.list and Update System
	cat > /etc/apt/sources.list.d/openmediavault.list <<- EOF
	deb https://openmediavault.github.io/packages/ ${OMV_Name} main
	## Uncomment the following line to add software from the proposed repository.
	deb https://openmediavault.github.io/packages/ ${OMV_Name}-proposed main

	## This software is not part of OpenMediaVault, but is offered by third-party
	## developers as a service to OpenMediaVault users.
	# deb https://openmediavault.github.io/packages/ ${OMV_Name} partner
	EOF

	# Add OMV and OMV Plugin developer keys, add Cloudshell 2 repo for XU4
	if [ "${BOARD}" = "odroidxu4" ]; then
		add-apt-repository -y ppa:kyle1117/ppa
		sed -i 's/jessie/xenial/' /etc/apt/sources.list.d/kyle1117-ppa-jessie.list
	fi
	mount --bind /dev/null /proc/mdstat
	apt-get update
	apt-get --yes --force-yes --allow-unauthenticated install openmediavault-keyring
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7AA630A1EDEE7D73
	apt-get update

	# install debconf-utils, postfix and OMV
	HOSTNAME="${BOARD}"
	debconf-set-selections <<< "postfix postfix/mailname string ${HOSTNAME}"
	debconf-set-selections <<< "postfix postfix/main_mailer_type string 'No configuration'"
	apt-get --yes --force-yes --allow-unauthenticated  --fix-missing --no-install-recommends \
		-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
		debconf-utils postfix
	# move newaliases temporarely out of the way (see Ubuntu bug 1531299)
	cp -p /usr/bin/newaliases /usr/bin/newaliases.bak && ln -sf /bin/true /usr/bin/newaliases
	sed -i -e "s/^::1         localhost.*/::1         ${HOSTNAME} localhost ip6-localhost ip6-loopback/" \
		-e "s/^127.0.0.1   localhost.*/127.0.0.1   ${HOSTNAME} localhost/" /etc/hosts
	sed -i -e "s/^mydestination =.*/mydestination = ${HOSTNAME}, localhost.localdomain, localhost/" \
		-e "s/^myhostname =.*/myhostname = ${HOSTNAME}/" /etc/postfix/main.cf
	apt-get --yes --force-yes --allow-unauthenticated  --fix-missing --no-install-recommends \
		-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install \
		openmediavault

	# install OMV extras, enable folder2ram and tweak some settings
	FILE=$(mktemp)
	wget "$OMV_EXTRAS_URL" -qO $FILE && dpkg -i $FILE

	/usr/sbin/omv-update
	# Install flashmemory plugin and netatalk by default, use nice logo for the latter,
	# tweak some OMV settings
	. /usr/share/openmediavault/scripts/helper-functions
	apt-get -y -q install openmediavault-netatalk openmediavault-flashmemory
	AFP_Options="mimic model = Macmini"
	SMB_Options="min receivefile size = 16384\nwrite cache size = 524288\ngetwd cache = yes\nsocket options = TCP_NODELAY IPTOS_LOWDELAY"
	xmlstarlet ed -L -u "/config/services/afp/extraoptions" -v "$(echo -e "${AFP_Options}")" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/services/smb/extraoptions" -v "$(echo -e "${SMB_Options}")" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/services/flashmemory/enable" -v "1" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/services/ssh/enable" -v "1" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/services/ssh/permitrootlogin" -v "0" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/system/time/ntp/enable" -v "1" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/system/time/timezone" -v "UTC" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/system/network/dns/hostname" -v "${HOSTNAME}" /etc/openmediavault/config.xml
	xmlstarlet ed -L -u "/config/system/monitoring/perfstats/enable" -v "0" /etc/openmediavault/config.xml
	echo -e "OMV_CPUFREQUTILS_GOVERNOR=${GOVERNOR}" >>/etc/default/openmediavault
	echo -e "OMV_CPUFREQUTILS_MINSPEED=${MIN_SPEED}" >>/etc/default/openmediavault
	echo -e "OMV_CPUFREQUTILS_MAXSPEED=${MAX_SPEED}" >>/etc/default/openmediavault
	for i in netatalk samba flashmemory ssh ntp timezone interfaces cpufrequtils monit collectd rrdcached ; do
		/usr/sbin/omv-mkconf $i
	done
	/sbin/folder2ram -enablesystemd || true
	sed -i 's|-j /var/lib/rrdcached/journal/ ||' /etc/init.d/rrdcached

	# Fix multiple sources entry on ARM with OMV4
	sed -i '/stretch-backports/d' /etc/apt/sources.list

	# rootfs resize to 7.3G max and adding omv-initsystem to firstrun -- q&d but shouldn't matter
	echo 15500000s >/root/.rootfs_resize
	sed -i '/systemctl\ disable\ armbian-firstrun/i \
	mv /usr/bin/newaliases.bak /usr/bin/newaliases \
	export DEBIAN_FRONTEND=noninteractive \
	sleep 3 \
	apt-get install -f -qq python-pip python-setuptools || exit 0 \
	pip install -U tzupdate \
	tzupdate \
	read TZ </etc/timezone \
	/usr/sbin/omv-initsystem \
	xmlstarlet ed -L -u "/config/system/time/timezone" -v "${TZ}" /etc/openmediavault/config.xml \
	/usr/sbin/omv-mkconf timezone \
	lsusb | egrep -q "0b95:1790|0b95:178a|0df6:0072" || sed -i "/ax88179_178a/d" /etc/modules' /usr/lib/armbian/armbian-firstrun
	sed -i '/systemctl\ disable\ armbian-firstrun/a \
	sleep 30 && sync && reboot' /usr/lib/armbian/armbian-firstrun

	# add USB3 Gigabit Ethernet support
	echo -e "r8152\nax88179_178a" >>/etc/modules

	# Special treatment for ODROID-XU4 (and later Amlogic S912, RK3399 and other big.LITTLE
	# based devices). Move all NAS daemons to the big cores. With ODROID-XU4 a lot
	# more tweaks are needed. CS2 repo added, CS1 workaround added, coherent_pool=1M
	# set: https://forum.odroid.com/viewtopic.php?f=146&t=26016&start=200#p197729
	# (latter not necessary any more since we fixed it upstream in Armbian)
	case ${BOARD} in
		odroidxu4)
			HMP_Fix='; taskset -c -p 4-7 $i '
			# Cloudshell stuff (fan, lcd, missing serials on 1st CS2 batch)
			echo "H4sIAKdXHVkCA7WQXWuDMBiFr+eveOe6FcbSrEIH3WihWx0rtVbUFQqCqAkYGhJn
			tF1x/vep+7oebDfh5DmHwJOzUxwzgeNIpRp9zWRegDPznya4VDlWTXXbpS58XJtD
			i7ICmFBFxDmgI6AXSLgsiUop54gnBC40rkoVA9rDG0SHHaBHPQx16GN3Zs/XqxBD
			leVMFNAz6n6zSWlEAIlhEw8p4xTyFtwBkdoJTVIJ+sz3Xa9iZEMFkXk9mQT6cGSQ
			QL+Cr8rJJSmTouuuRzfDtluarm1aLVHksgWmvanm5sbfOmY3JEztWu5tV9bCXn4S
			HB8RIzjoUbGvFvPw/tmr0UMr6bWSBupVrulY2xp9T1bruWnVga7DdAqYFgkuCd3j
			vORUDQgej9HPJxmDDv+3WxblBSuYFH8oiNpHz8XvPIkU9B3JVCJ/awIAAA==" \
			| tr -d '[:blank:]' | base64 --decode | gunzip -c >/usr/local/sbin/cloudshell2-support.sh
			chmod 755 /usr/local/sbin/cloudshell2-support.sh
			apt install -y i2c-tools odroid-cloudshell cloudshell2-fan
			sed -i '/systemctl\ disable\ armbian-firstrun/i \
			lsusb | grep -q -i "05e3:0735" && sed -i "/exit\ 0/i echo 20 > /sys/class/block/sda/queue/max_sectors_kb" /etc/rc.local \
			/usr/sbin/i2cdetect -y 1 | grep -q "60: 60" && /usr/local/sbin/cloudshell2-support.sh' /usr/lib/armbian/armbian-firstrun
			;;
		bananapim3|nanopifire3|nanopct3plus|nanopim3)
			HMP_Fix='; taskset -c -p 4-7 $i '
			;;
		edge*|ficus|firefly-rk3399|nanopct4|nanopim4|nanopineo4|renegade-elite|roc-rk3399-pc|rockpro64|station-p1)
			HMP_Fix='; taskset -c -p 4-5 $i '
			;;
	esac
	echo "* * * * * root for i in \`pgrep \"ftpd|nfsiod|smbd|afpd|cnid\"\` ; do ionice -c1 -p \$i ${HMP_Fix}; done >/dev/null 2>&1" \
		>/etc/cron.d/make_nas_processes_faster
	chmod 600 /etc/cron.d/make_nas_processes_faster

	# add SATA port multiplier hint if appropriate
	[ "${LINUXFAMILY}" = "sunxi" ] && \
		echo -e "#\n# If you want to use a SATA PM add \"ahci_sunxi.enable_pmp=1\" to bootargs above" \
		>>/boot/boot.cmd

	# Filter out some log messages
	echo ':msg, contains, "do ionice -c1" ~' >/etc/rsyslog.d/omv-armbian.conf
	echo ':msg, contains, "action " ~' >>/etc/rsyslog.d/omv-armbian.conf
	echo ':msg, contains, "netsnmp_assert" ~' >>/etc/rsyslog.d/omv-armbian.conf
	echo ':msg, contains, "Failed to initiate sched scan" ~' >>/etc/rsyslog.d/omv-armbian.conf

	# Fix little python bug upstream Debian 9 obviously ignores
	if [ -f /usr/lib/python3.5/weakref.py ]; then
		wget -O /usr/lib/python3.5/weakref.py \
		https://raw.githubusercontent.com/python/cpython/9cd7e17640a49635d1c1f8c2989578a8fc2c1de6/Lib/weakref.py
	fi

	# clean up and force password change on first boot
	umount /proc/mdstat
	chage -d 0 root
} # InstallOpenMediaVault

UnattendedStorageBenchmark() {
	# Function to create Armbian images ready for unattended storage performance testing.
	# Useful to use the same OS image with a bunch of different SD cards or eMMC modules
	# to test for performance differences without wasting too much time.

	rm /root/.not_logged_in_yet

	apt-get -qq install time

	wget -qO /usr/local/bin/sd-card-bench.sh https://raw.githubusercontent.com/ThomasKaiser/sbc-bench/master/sd-card-bench.sh
	chmod 755 /usr/local/bin/sd-card-bench.sh

	sed -i '/^exit\ 0$/i \
	/usr/local/bin/sd-card-bench.sh &' /etc/rc.local
} # UnattendedStorageBenchmark

InstallAdvancedDesktop()
{
	apt-get install -yy transmission libreoffice libreoffice-style-tango meld remmina thunderbird kazam avahi-daemon
	[[ -f /usr/share/doc/avahi-daemon/examples/sftp-ssh.service ]] && cp /usr/share/doc/avahi-daemon/examples/sftp-ssh.service /etc/avahi/services/
	[[ -f /usr/share/doc/avahi-daemon/examples/ssh.service ]] && cp /usr/share/doc/avahi-daemon/examples/ssh.service /etc/avahi/services/
	apt clean
} # InstallAdvancedDesktop

Main "$@"
