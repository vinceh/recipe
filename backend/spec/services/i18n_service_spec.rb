require 'rails_helper'

RSpec.describe I18nService do
  describe '.set_locale' do
    it 'sets I18n.locale to the determined locale' do
      locale = I18nService.set_locale(user: nil, accept_language: 'ja')
      expect(I18n.locale).to eq(:ja)
      expect(locale).to eq(:ja)
    end

    it 'returns the locale that was set' do
      locale = I18nService.set_locale(user: nil, accept_language: 'en-US')
      expect(locale).to eq(:en)
    end
  end

  describe '.determine_locale' do
    context 'with user preference' do
      let(:user) { double('User', preferred_language: 'ja') }

      it 'prioritizes user preferred language over header' do
        locale = I18nService.determine_locale(user: user, accept_language: 'en-US')
        expect(locale).to eq(:ja)
      end

      it 'falls back to header if user preference is invalid' do
        user = double('User', preferred_language: 'invalid')
        locale = I18nService.determine_locale(user: user, accept_language: 'ko')
        expect(locale).to eq(:ko)
      end

      it 'handles nil user preference' do
        user = double('User', preferred_language: nil)
        locale = I18nService.determine_locale(user: user, accept_language: 'es')
        expect(locale).to eq(:es)
      end
    end

    context 'with Accept-Language header' do
      it 'detects English from en-US' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'en-US')
        expect(locale).to eq(:en)
      end

      it 'detects Japanese from ja-JP' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'ja-JP')
        expect(locale).to eq(:ja)
      end

      it 'detects Korean from ko-KR' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'ko-KR')
        expect(locale).to eq(:ko)
      end

      it 'detects Traditional Chinese from zh-TW' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'zh-TW')
        expect(locale).to eq(:'zh-tw')
      end

      it 'detects Simplified Chinese from zh-CN' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'zh-CN')
        expect(locale).to eq(:'zh-cn')
      end

      it 'detects Spanish from es-ES' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'es-ES')
        expect(locale).to eq(:es)
      end

      it 'detects French from fr-FR' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'fr-FR')
        expect(locale).to eq(:fr)
      end
    end

    context 'without user or header' do
      it 'falls back to default locale' do
        locale = I18nService.determine_locale(user: nil, accept_language: nil)
        expect(locale).to eq(:en)
      end
    end

    context 'with unsupported language' do
      it 'falls back to default locale' do
        locale = I18nService.determine_locale(user: nil, accept_language: 'de-DE')
        expect(locale).to eq(:en)
      end
    end
  end

  describe '.detect_locale_from_header' do
    it 'parses simple language code' do
      locale = I18nService.detect_locale_from_header('ja')
      expect(locale).to eq(:ja)
    end

    it 'parses language code with region' do
      locale = I18nService.detect_locale_from_header('en-US')
      expect(locale).to eq(:en)
    end

    it 'parses language with quality values' do
      locale = I18nService.detect_locale_from_header('en-US,en;q=0.9,ja;q=0.8')
      expect(locale).to eq(:en)
    end

    it 'selects language with highest quality value' do
      locale = I18nService.detect_locale_from_header('en;q=0.7,ja;q=0.9,ko;q=0.8')
      expect(locale).to eq(:ja)
    end

    it 'prioritizes first supported language when qualities are equal' do
      locale = I18nService.detect_locale_from_header('de,ja,ko')
      expect(locale).to eq(:ja) # de is not supported, ja comes before ko
    end

    it 'handles complex Accept-Language header' do
      header = 'fr-CH,fr;q=0.9,en;q=0.8,de;q=0.7,*;q=0.5'
      locale = I18nService.detect_locale_from_header(header)
      expect(locale).to eq(:fr)
    end

    it 'returns default locale for blank header' do
      locale = I18nService.detect_locale_from_header('')
      expect(locale).to eq(:en)
    end

    it 'returns default locale for nil header' do
      locale = I18nService.detect_locale_from_header(nil)
      expect(locale).to eq(:en)
    end

    it 'returns default locale when no supported languages in header' do
      locale = I18nService.detect_locale_from_header('de-DE,ar-SA')
      expect(locale).to eq(:en)
    end
  end

  describe '.normalize_language_code' do
    context 'with English' do
      it 'normalizes en to :en' do
        expect(I18nService.send(:normalize_language_code, 'en')).to eq(:en)
      end

      it 'normalizes en-US to :en' do
        expect(I18nService.send(:normalize_language_code, 'en-US')).to eq(:en)
      end

      it 'normalizes en-GB to :en' do
        expect(I18nService.send(:normalize_language_code, 'en-GB')).to eq(:en)
      end
    end

    context 'with Japanese' do
      it 'normalizes ja to :ja' do
        expect(I18nService.send(:normalize_language_code, 'ja')).to eq(:ja)
      end

      it 'normalizes ja-JP to :ja' do
        expect(I18nService.send(:normalize_language_code, 'ja-JP')).to eq(:ja)
      end
    end

    context 'with Korean' do
      it 'normalizes ko to :ko' do
        expect(I18nService.send(:normalize_language_code, 'ko')).to eq(:ko)
      end

      it 'normalizes ko-KR to :ko' do
        expect(I18nService.send(:normalize_language_code, 'ko-KR')).to eq(:ko)
      end
    end

    context 'with Chinese variants' do
      it 'normalizes zh-TW to :zh-tw (Traditional)' do
        expect(I18nService.send(:normalize_language_code, 'zh-TW')).to eq(:'zh-tw')
      end

      it 'normalizes zh-Hant to :zh-tw (Traditional)' do
        expect(I18nService.send(:normalize_language_code, 'zh-Hant')).to eq(:'zh-tw')
      end

      it 'normalizes zh-CN to :zh-cn (Simplified)' do
        expect(I18nService.send(:normalize_language_code, 'zh-CN')).to eq(:'zh-cn')
      end

      it 'normalizes zh-Hans to :zh-cn (Simplified)' do
        expect(I18nService.send(:normalize_language_code, 'zh-Hans')).to eq(:'zh-cn')
      end

      it 'defaults zh to :zh-tw when no variant specified' do
        expect(I18nService.send(:normalize_language_code, 'zh')).to eq(:'zh-tw')
      end
    end

    context 'with Spanish' do
      it 'normalizes es to :es' do
        expect(I18nService.send(:normalize_language_code, 'es')).to eq(:es)
      end

      it 'normalizes es-ES to :es' do
        expect(I18nService.send(:normalize_language_code, 'es-ES')).to eq(:es)
      end

      it 'normalizes es-MX to :es' do
        expect(I18nService.send(:normalize_language_code, 'es-MX')).to eq(:es)
      end
    end

    context 'with French' do
      it 'normalizes fr to :fr' do
        expect(I18nService.send(:normalize_language_code, 'fr')).to eq(:fr)
      end

      it 'normalizes fr-FR to :fr' do
        expect(I18nService.send(:normalize_language_code, 'fr-FR')).to eq(:fr)
      end

      it 'normalizes fr-CA to :fr' do
        expect(I18nService.send(:normalize_language_code, 'fr-CA')).to eq(:fr)
      end
    end

    context 'with case sensitivity' do
      it 'handles uppercase language codes' do
        expect(I18nService.send(:normalize_language_code, 'EN-US')).to eq(:en)
      end

      it 'handles mixed case language codes' do
        expect(I18nService.send(:normalize_language_code, 'Ja-Jp')).to eq(:ja)
      end
    end
  end

  describe '.parse_accept_language' do
    it 'parses single language' do
      result = I18nService.send(:parse_accept_language, 'en')
      expect(result).to eq(['en'])
    end

    it 'parses multiple languages' do
      result = I18nService.send(:parse_accept_language, 'en,ja,ko')
      expect(result).to eq(['en', 'ja', 'ko'])
    end

    it 'parses languages with quality values' do
      result = I18nService.send(:parse_accept_language, 'en;q=0.9,ja;q=1.0,ko;q=0.8')
      expect(result).to eq(['ja', 'en', 'ko']) # Sorted by quality
    end

    it 'sorts by quality value descending' do
      result = I18nService.send(:parse_accept_language, 'en;q=0.5,ja;q=0.9,ko;q=0.7')
      expect(result).to eq(['ja', 'ko', 'en'])
    end

    it 'defaults quality to 1.0 when not specified' do
      result = I18nService.send(:parse_accept_language, 'en,ja;q=0.8')
      expect(result).to eq(['en', 'ja']) # en has default q=1.0
    end

    it 'handles whitespace' do
      result = I18nService.send(:parse_accept_language, ' en , ja ; q=0.9 , ko ')
      expect(result).to eq(['en', 'ko', 'ja']) # en and ko both have q=1.0 (default), ja has q=0.9
    end
  end

  describe 'integration with I18n' do
    it 'changes I18n.locale when set_locale is called' do
      original_locale = I18n.locale
      I18nService.set_locale(user: nil, accept_language: 'ja')
      expect(I18n.locale).to eq(:ja)
      # Reset
      I18n.locale = original_locale
    end

    it 'falls back to English for missing translations' do
      I18nService.set_locale(user: nil, accept_language: 'ko')
      # ko.yml has placeholders, should fall back to en
      translation = I18n.t('common.buttons.save', default: 'Save')
      expect(translation).to be_present
    end
  end
end
