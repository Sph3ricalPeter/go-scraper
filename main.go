package main

import (
	"github.com/playwright-community/playwright-go"
	"log/slog"
)

const (
	url = "https://www.whatsmyip.org/"
)

func main() {
	log := slog.Default()

	log.Info("Starting playwright ...")
	pw, err := playwright.Run()
	pErr(err)

	browser, err := pw.Chromium.Launch(playwright.BrowserTypeLaunchOptions{
		Headless: playwright.Bool(true),
	})
	pErr(err)

	page, err := browser.NewPage(playwright.BrowserNewPageOptions{
		Screen: &playwright.Size{Width: 1920, Height: 1080},
	})
	pErr(err)

	log.Info("Navigating to", "url", url)
	_, err = page.Goto(url)
	pErr(err)

	log.Info("Getting IP Address ...")
	ip, err := page.Locator("//span[@id=\"ip\"]").TextContent()
	pErr(err)

	log.Info("IP Address", "ip", ip)
}

func pErr(err error) {
	if err != nil {
		panic(err)
	}
}
