//
//  TipManager.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-08-19.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation;
import UIKit;

public class Tip : NSObject, Codable {
    
    public var title:String;
    public var paragraph:String;
    public var isDiscovered:Bool = false;
    
    init(title:String, paragraph:String) {
        self.title = title;
        self.paragraph = paragraph;
    }
    
}

public class TipManager {
    
    private static var tips:Array<Tip> = Array<Tip>();
    private static var tipsHolder = [Tip(title: "Keep calm and trade on!", paragraph: "Take it easy while trading: They say the best traders mastered the art of maintaining their cool even when things seem to be out of hand. You have to develop the skill of not trading emotionally, but objectively. Understanding this principle is the first step that a beginner trader needs to master. \n\n Remember to always be rational."), Tip(title: "Expect the unexpected", paragraph: "However, significant volatility does exist in cryptocurrency markets which cannot be ignored. Experienced cryptocurrency investors are accustomed to huge price swings that you often don’t find in traditional markets. By mentally preparing for these unfavorable, and occasionally terrifying, investment performances, the intelligent crypto investor will be able to act rationally instead of emotionally in times of unexpected price drops."), Tip(title: "Avoid a bad trade or investment strategy", paragraph: "A common mistake for beginner cryptocurrency investors is joining what is known as a pump and dump group. Certain social media communities or ‘gurus’ may even promise investment tips regarding a particular coin. You should avoid these types of places at all costs; when travelers go down these roads, they don’t often come back. The problem is that since derivatives trading is a zero-sum game, there is always a winner, but more importantly a loser. Unless a solid trading or investment strategy is in place, heedlessly following such advice is the fast track to losing your money to modern-day snake oil salesmen. If you’re interested in learning more about strategic trading and algorithmic strategies, check out our series of articles on our Alpha Predator Model."),Tip(title: "Perform your due diligence", paragraph: "In this modern digital age, there is even wifi on the path to crypto investing enlightenment, hence there is no excuse to make an investment with little to no understanding of the underlying asset. Almost every single coin has easily accessible whitepapers online. And just like having maps in the car, the savvy traveler must be prepared. From the heavily traded to the most niche, resources such as the All Crypto Whitepapers will help any individual brush up their knowledge on potential future investments. If it is impossible to tell how the coin operates and more importantly, makes money, then it would be wise to seek another investment opportunity. From the biggest initial coin offerings (ICOs) to the most niche altcoins."), Tip(title: "Don't place all your crypto-coins in one basket", paragraph: "Common investment wisdom prevails when it comes to cryptocurrency investment: diversification is key. Just as financial advisors recommend taking positions in multiple types of stocks and other investments, diversification is also essential for any healthy cryptocurrency portfolio. You've done your research, so now seize the opportunity to invest in multiple coins. As one example, you can invest across different sectors which serve different use cases. Just like it’s always safer to travel as a group then as a single person when you’re in unfamiliar territory, establishing a diversified portfolio will help you along your path toward realizing potential future cryptocurrency gains."), Tip(title: "Don't Sweat the Small Stuff", paragraph: "Rather than panic over an investment’s short-term movements, it’s better to track its big-picture trajectory. Have confidence in an investment’s larger story, and don’t be swayed by short-term volatility."), Tip(title: "Bull Market", paragraph: "A bull market is a market that is on the rise and where the conditions of the economy are generally favorable. A bear market exists in an economy that is receding and where most stocks are declining in value. Because the financial markets are greatly influenced by investors' attitudes, these terms also denote how investors feel about the market and the ensuing economic trends. A bull market is typified by a sustained increase in prices. In the case of equity markets, in equity markets in the prices of companies' shares. In such times, investors often have faith that the uptrend will continue over the long term. Typically, in this scenario, the country's economy is strong and employment levels are high."), Tip(title: "Bear Market", paragraph: "A bear market is one that is in decline, typically having fallen 20% or more from recent highs. Share prices are continuously dropping, resulting in a downward trend that investors believe will continue, which, in turn, perpetuates the downward spiral. During a bear market, the economy will typically slow down and unemployment will rise as companies begin laying off workers."), Tip(title: "Fundamental Analysis", paragraph: "Fundamental analysis deeply analyzes the underlying factors that give an asset value, making it a good investment or not. In traditional assets like stocks or commodities, company financials or manufacturing reports can be a barometer for fundamental analysis. But cryptocurrencies often lack utility or a centralized authority that gives the asset value. Instead, value is derived from things like scarcity, or the value being transacted across each cryptocurrency’s underlying blockchain network. Some traditional fundamental analysis still applies, such as considering a project’s white paper or the team backing a product. But fundamental analysis is more for investors who are considering which long term entries to take, while technical analysis is geared more for traders who seek to use the practice to gain a competitive edge in the market."), Tip(title: "Technical Analysis", paragraph: "Technical analysis is the study, practice, and analysis of chart patterns, indicators and oscillators, and the candlesticks themselves that make up price charts of assets like stocks, cryptocurrencies, forex and more."), Tip(title: "Relative Strength Index (RSI)", paragraph: "The Relative Strength Index (RSI), developed by J. Welles Wilder, is a momentum oscillator that measures the speed and change of price movements. The RSI oscillates between zero and 100. Traditionally the RSI is considered overbought when above 70 and oversold when below 30. Signals can be generated by looking for divergences and failure swings. RSI can also be used to identify the general trend. RSI is considered overbought when above 70 and oversold when below 30. These traditional levels can also be adjusted if necessary to better fit the security. For example, if a security is repeatedly reaching the overbought level of 70 you may want to adjust this level to 80.\n Note: During strong trends, the RSI may remain in overbought or oversold for extended periods. \n RSI also often forms chart patterns that may not show on the underlying price chart, such as double tops and bottoms and trend lines. Also, look for support or resistance on the RSI. \n In an uptrend or bull market, the RSI tends to remain in the 40 to 90 range with the 40-50 zone acting as support. During a downtrend or bear market the RSI tends to stay between the 10 to 60 range with the 50-60 zone acting as resistance. These ranges will vary depending on the RSI settings and the strength of the security’s or market’s underlying trend.\n If underlying prices make a new high or low that isn't confirmed by the RSI, this divergence can signal a price reversal. If the RSI makes a lower high and then follows with a downside move below a previous low, a Top Swing Failure has occurred. If the RSI makes a higher low and then follows with an upside move above a previous high, a Bottom Swing Failure has occurred."), Tip(title: "Pick a Strategy and Stick With It", paragraph: "There are many ways to pick cryptocurrencies, and it’s important to stick with a single philosophy. Vacillating between different approaches effectively makes you a market timer, which is dangerous territory. Consider how noted investor Warren Buffett stuck to his value-oriented strategy, and steered clear of the dotcom boom of the late '90s—consequently avoiding major losses when tech startups crashed."), Tip(title: "Moving Average Convergence Divergence (MACD)", paragraph: " MACD, short for moving average convergence/divergence, is a trading indicator used in technical analysis of stock/cryptocurrency prices, created by Gerald Appel in the late 1970s. It is designed to reveal changes in the strength, direction, momentum, and duration of a trend in a stock's/cryptocurrency’s price."), Tip(title: "Have a motive for entering each trade", paragraph: "Now, I know this may sound obvious but it’s important for you to have a clear purpose for getting into cryptocurrency trade. Whether your purpose is to day trade or to scalp, you need to have a purpose for starting to trade cryptos. Trading digital currencies is a zero-sum game; you need to realize that for every win, there is a corresponding loss:. Someone wins; someone else loses. \n The cryptocurrency market is controlled by the large ‘whales’, pretty much like the ones that place thousands of Bitcoins in the market order books. And can you guess what these whales do best? They have patience; they wait for innocent traders like you and me to make a single mistake that lands our money to their hands due to avoidable mistakes. \n Whether you are a day trader or scalper, sometimes you’re better off not gaining anything on a certain trade than rushing your way into losses."), Tip(title: "Welcome to FOMO!", paragraph: "FOMO is an abbreviation for the fear of missing out. This is one of the most notorious reasons as to why many traders fail in the art. From an outside point of view, it is never a good scene seeing people make massive profits within minutes from pumped-up coins. Honestly, I never like such situations any more than you do.\n But I’ll tell you one thing that’s for sure…\n Beware of that moment when the green candles seem to be screaming at you and telling to you to jump in. It is at this point that the whales will be smiling and watching you buy the coins they bought earlier at very low prices. Guess what normally follows? These coins usually end up in the hands of small traders and the next thing that happens is for the red candles to start popping up due to an oversupply and, voila, losses start trickling in."), Tip(title: "Ignore the noise", paragraph: "Many naysayers in the media and financial sectors may preach that cryptocurrency is simply a fad, over-hyped speculation, or even a pyramid scheme. On the other hand, a growing population increasingly embraces the financial prospects and practical applications of cryptocurrency assets. Both sides have loud voices and like to make a lot of noise. This noise level is only expected to increase, as Satis Group predicted cryptocurrency trading activity for personal investors will increase by 50% in 2019.To be a successful investor in this space, it is best to just buy and hold what you believe in while ignoring all the noise around you."), Tip(title: "Altcoin", paragraph: "Altcoins are the other cryptocurrencies launched after the success of Bitcoin. Generally, they sell themselves as better alternatives to Bitcoin. The term altcoins refers to all cryptocurrencies other than Bitcoin. As of early 2020, there were more than 5,000 cryptocurrencies by some estimates. According to CoinMarketCap, altcoins accounted for over 34% of the total cryptocurrency market in February 2020."), Tip(title: "Sentiment", paragraph: "In finance, the term sentiment (or market sentiment) refers to the highly subjective feeling about the state of a market. It is the overall emotion that traders and investors have in regards to the price action of a particular asset.")];
    private static let length:Int = TipManager.tipsHolder.count;
    
    // Tip(title: "Best Websites for chart analysis", paragraph: "CryptoWatch\nTrading View\n CoinMarketCap:\nBitfinex")
    
    public static func createTipList() -> Array<Tip> {
        if (!self.tips.isEmpty) { self.tips.removeAll(); }
        for _ in 0...self.length - 1 {
            self.tips.append(Tip(title: "?", paragraph: ""));
        }
        saveTipList()
        return self.tips;
    }
    
    public static func saveTipList() -> Void {
        DataStorageHandler.saveObject(type: self.tips, forKey: UserDefaultKeys.investingTipsKey);
    }
    
    public static func loadTipList() -> Array<Tip>? {
        if let investingTips = DataStorageHandler.loadObject(type: [Tip].self, forKey: UserDefaultKeys.investingTipsKey) {
            self.tips = investingTips;
            return self.tips;
        } else {
            return nil;
        }
    }
    
    public static func addRandomTip() -> Void {
        if (self.tips.isEmpty) {
            if let loadedTips = TipManager.loadTipList() {
                self.tips = loadedTips;
            } else {
                self.tips = createTipList();
            }
        }
        if (self.tips[0].title == "?") {
            UserDefaults.standard.set(0, forKey: UserDefaultKeys.randomIndex);
            self.tips[0] = self.tipsHolder[0];
            saveTipList();
            return;
        }
        var index:Int = 1;
        while (true) {
            index = index + 1;
            if (index == self.length - 1) {
                if (self.tips.filter({$0.title != "?"}).count != self.tipsHolder.count) {
                    index = 1;
                    continue;
                } else {
                    UserDefaults.standard.set(true, forKey: UserDefaultKeys.foundAllTips);
                    break;
                }
            }
            let rndIndex = Int.random(in: 1...self.tipsHolder.count - 1);
            let loadedIndex = UserDefaults.standard.integer(forKey: UserDefaultKeys.randomIndex);
            if (self.tips[rndIndex].title == "?") {
                if (loadedIndex != rndIndex) {
                    UserDefaults.standard.set(rndIndex, forKey: UserDefaultKeys.randomIndex);
                    self.tips[rndIndex] = self.tipsHolder[rndIndex];
                    saveTipList();
                    if (self.tips.filter({$0.title != "?"}).count == self.tipsHolder.count) {
                        UserDefaults.standard.set(true, forKey: UserDefaultKeys.foundAllTips);
                    }
                    return;
                }
            }
        }
    }
    
    
    
}
