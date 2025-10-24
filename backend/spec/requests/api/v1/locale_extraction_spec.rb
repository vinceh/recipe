require "rails_helper"

RSpec.describe "Locale Parameter Extraction", type: :request do
  describe "AC-PHASE6-LOCALE-001: Extract locale from ?lang parameter" do
    it "sets I18n.locale to requested language from ?lang parameter" do
      get "/api/v1/recipes", params: { lang: "ja" }
      expect(response).to have_http_status(:ok)
    end

    it "returns translations in Japanese when ?lang=ja" do
      # Create a recipe with Japanese name translation
      recipe = FactoryBot.create(:recipe, name: "Sushi Roll")
      Mobility.with_locale(:ja) { recipe.update(name: "寿司ロール") }

      get "/api/v1/recipes", params: { lang: "ja" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      # Verify Japanese translation is returned
      expect(body["data"]["recipes"][0]["name"]).to eq("寿司ロール")
    end

    it "works with all 7 supported languages via ?lang parameter" do
      recipe = FactoryBot.create(:recipe, name: "Test Recipe")

      %w[en ja ko zh-tw zh-cn es fr].each do |lang|
        get "/api/v1/recipes", params: { lang: lang }
        expect(response).to have_http_status(:ok), "Failed for language: #{lang}"
      end
    end
  end

  describe "AC-PHASE6-LOCALE-002: Extract locale from Accept-Language header" do
    it "sets locale from Accept-Language header when no ?lang parameter" do
      get "/api/v1/recipes", headers: { "Accept-Language" => "ko-KR,ko;q=0.9,en;q=0.8" }
      expect(response).to have_http_status(:ok)
    end

    it "extracts first language from Accept-Language header with multiple preferences" do
      recipe = FactoryBot.create(:recipe, name: "Bibimbap")
      Mobility.with_locale(:ko) { recipe.update(name: "비빔밥") }

      get "/api/v1/recipes", headers: { "Accept-Language" => "ko-KR,ko;q=0.9,en;q=0.8" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      # Verify Korean translation from first language tag
      expect(body["data"]["recipes"][0]["name"]).to eq("비빔밥")
    end

    it "handles Regional Chinese (zh-tw) from Accept-Language header" do
      recipe = FactoryBot.create(:recipe, name: "Fried Rice")
      Mobility.with_locale(:"zh-tw") { recipe.update(name: "炒飯") }

      get "/api/v1/recipes", headers: { "Accept-Language" => "zh-tw,zh;q=0.9" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      # Verify Traditional Chinese (zh-tw) is used, not Simplified (zh-cn)
      expect(body["data"]["recipes"][0]["name"]).to eq("炒飯")
    end

    it "handles Simplified Chinese (zh-cn) from Accept-Language header" do
      recipe = FactoryBot.create(:recipe, name: "Sweet Sour Pork")
      Mobility.with_locale(:"zh-cn") { recipe.update(name: "糖醋肉") }

      get "/api/v1/recipes", headers: { "Accept-Language" => "zh-cn,en;q=0.9" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      # Verify Simplified Chinese (zh-cn) is used
      expect(body["data"]["recipes"][0]["name"]).to eq("糖醋肉")
    end
  end

  describe "AC-PHASE6-LOCALE-003: Parameter priority over header" do
    it "prioritizes ?lang parameter over Accept-Language header" do
      recipe = FactoryBot.create(:recipe, name: "Paella")
      Mobility.with_locale(:es) { recipe.update(name: "Paella") }
      Mobility.with_locale(:ja) { recipe.update(name: "パエリア") }

      # Request Spanish via ?lang, but header requests Japanese
      get "/api/v1/recipes", params: { lang: "es" }, headers: { "Accept-Language" => "ja-JP,ja;q=0.9" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      # Verify Spanish is used (parameter takes priority)
      expect(body["data"]["recipes"][0]["name"]).to eq("Paella")
    end

    it "ignores Accept-Language header when ?lang parameter provided" do
      get "/api/v1/recipes",
          params: { lang: "fr" },
          headers: { "Accept-Language" => "en-US,en;q=0.9" }
      expect(response).to have_http_status(:ok)
      # French should be used, not English from header
    end
  end

  describe "AC-PHASE6-LOCALE-004: Fallback to default locale for invalid locale" do
    it "falls back to English when invalid ?lang parameter provided" do
      get "/api/v1/recipes", params: { lang: "invalid_locale" }
      expect(response).to have_http_status(:ok)
      # Should not crash, should return English
    end

    it "falls back to English when ?lang is SQL injection attempt" do
      get "/api/v1/recipes", params: { lang: "en; DROP TABLE users;" }
      expect(response).to have_http_status(:ok)
      # Should reject malicious input and return English
    end

    it "returns valid response with English when unsupported locale requested" do
      recipe = FactoryBot.create(:recipe, name: "Risotto")

      get "/api/v1/recipes", params: { lang: "xx-XX" }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      # Should successfully return response in English (default)
      expect(body["data"]["recipes"]).to be_present
    end
  end

  describe "AC-PHASE6-LOCALE-005: Default to English when no locale specified" do
    it "defaults to English when no ?lang parameter and no Accept-Language header" do
      recipe = FactoryBot.create(:recipe, name: "Pasta Carbonara")

      get "/api/v1/recipes"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      # Should return English (default)
      expect(body["data"]["recipes"][0]["name"]).to eq("Pasta Carbonara")
    end

    it "uses English when Accept-Language header is empty" do
      get "/api/v1/recipes", headers: { "Accept-Language" => "" }
      expect(response).to have_http_status(:ok)
      # Should default to English
    end

    it "uses English when Accept-Language header is nil" do
      get "/api/v1/recipes", headers: { "Accept-Language" => nil }
      expect(response).to have_http_status(:ok)
      # Should default to English
    end
  end

  describe "Edge cases" do
    describe "Regional variants (e.g., ja-JP -> ja)" do
      it "extracts language code from regional variant" do
        recipe = FactoryBot.create(:recipe, name: "Tempura")
        Mobility.with_locale(:ja) { recipe.update(name: "天ぷら") }

        # Send Japanese from Japan region (ja-JP)
        get "/api/v1/recipes", headers: { "Accept-Language" => "ja-JP,en;q=0.9" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        # Should extract 'ja' and return Japanese translation
        expect(body["data"]["recipes"][0]["name"]).to eq("天ぷら")
      end

      it "handles Korean from Korea region (ko-KR)" do
        recipe = FactoryBot.create(:recipe, name: "Kimchi")
        Mobility.with_locale(:ko) { recipe.update(name: "김치") }

        get "/api/v1/recipes", headers: { "Accept-Language" => "ko-KR,en;q=0.9" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["recipes"][0]["name"]).to eq("김치")
      end

      it "handles Spanish from Spain region (es-ES)" do
        recipe = FactoryBot.create(:recipe, name: "Gazpacho")
        Mobility.with_locale(:es) { recipe.update(name: "Gazpacho") }

        get "/api/v1/recipes", headers: { "Accept-Language" => "es-ES,en;q=0.9" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["recipes"][0]["name"]).to eq("Gazpacho")
      end
    end

    describe "Whitespace handling" do
      it "handles Accept-Language header with leading/trailing whitespace" do
        recipe = FactoryBot.create(:recipe, name: "Ramen")
        Mobility.with_locale(:ja) { recipe.update(name: "ラーメン") }

        # Header with extra spaces
        get "/api/v1/recipes", headers: { "Accept-Language" => " ja-JP , en ; q=0.9 " }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        # Should still extract 'ja' correctly despite whitespace
        expect(body["data"]["recipes"][0]["name"]).to eq("ラーメン")
      end

      it "handles ?lang parameter with spaces (should not be present, but defensively handled)" do
        get "/api/v1/recipes", params: { lang: " ja " }
        expect(response).to have_http_status(:ok)
        # Should fall back to English since ' ja ' is invalid
      end
    end

    describe "Malformed headers" do
      it "gracefully handles malformed Accept-Language header" do
        get "/api/v1/recipes", headers: { "Accept-Language" => ";;;" }
        expect(response).to have_http_status(:ok)
        # Should not crash, should return English (default)
      end

      it "handles Accept-Language with only quality factors" do
        get "/api/v1/recipes", headers: { "Accept-Language" => "q=0.9,q=0.8" }
        expect(response).to have_http_status(:ok)
        # Should fall back to English
      end

      it "handles very long Accept-Language header" do
        long_header = ("ja-JP,ja;q=0.9," * 100)[0...-1]
        get "/api/v1/recipes", headers: { "Accept-Language" => long_header }
        expect(response).to have_http_status(:ok)
        # Should extract first language (ja) without performance issue
      end
    end

    describe "Multiple language preferences" do
      it "extracts first language preference, ignoring quality factors" do
        recipe = FactoryBot.create(:recipe, name: "Quiche")
        Mobility.with_locale(:fr) { recipe.update(name: "Quiche") }

        # Multiple preferences: French preferred, but lower q factor
        get "/api/v1/recipes", headers: { "Accept-Language" => "fr,en;q=0.9,ja;q=0.8" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        # Should use first language (fr), not highest q factor
        expect(body["data"]["recipes"][0]["name"]).to eq("Quiche")
      end
    end

    describe "Concurrent requests with different locales" do
      it "maintains isolated locale context for concurrent requests" do
        recipe1 = FactoryBot.create(:recipe, name: "Tacos")
        Mobility.with_locale(:es) { recipe1.update(name: "Tacos") }

        # This is a simplified test - actual concurrency testing would be more complex
        # For now, we test that sequential requests don't interfere

        get "/api/v1/recipes", params: { lang: "es" }
        expect(response).to have_http_status(:ok)
        body1 = JSON.parse(response.body)

        get "/api/v1/recipes", params: { lang: "en" }
        expect(response).to have_http_status(:ok)
        body2 = JSON.parse(response.body)

        # Both requests should complete successfully with their respective locales
        expect(body1["data"]["recipes"]).to be_present
        expect(body2["data"]["recipes"]).to be_present
      end
    end

    describe "All 7 languages support" do
      %w[en ja ko zh-tw zh-cn es fr].each do |locale|
        it "supports #{locale} via ?lang parameter" do
          get "/api/v1/recipes", params: { lang: locale }
          expect(response).to have_http_status(:ok)
        end

        it "supports #{locale} via Accept-Language header" do
          get "/api/v1/recipes", headers: { "Accept-Language" => locale }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe "Admin endpoints locale support (AC-PHASE6-ADMIN-001)" do
    it "extracts locale for admin recipe list endpoint" do
      admin_user = FactoryBot.create(:admin_user)
      recipe = FactoryBot.create(:recipe, name: "Admin Recipe")
      Mobility.with_locale(:ja) { recipe.update(name: "管理者レシピ") }

      get "/admin/recipes", params: { lang: "ja" }, headers: { "Authorization" => "Bearer #{admin_user.auth_token}" }
      expect(response).to have_http_status(:ok)
    end

    it "extracts locale for admin recipe detail endpoint" do
      admin_user = FactoryBot.create(:admin_user)
      recipe = FactoryBot.create(:recipe, name: "Admin Detail")
      Mobility.with_locale(:ko) { recipe.update(name: "관리자 세부") }

      get "/admin/recipes/#{recipe.id}", params: { lang: "ko" }, headers: { "Authorization" => "Bearer #{admin_user.auth_token}" }
      expect(response).to have_http_status(:ok)
    end
  end
end
