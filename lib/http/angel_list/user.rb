module Http::AngelList
  class User < Base
    NOPIC = 'https://angel.co/images/shared/nopic.png'

    ROLES = {
      'seed funds' => :seed,
      'angels' => :angel,
      'vc' => :venture,
    }

    def image
      @data['image'] if found? && @data['image'] != NOPIC
    end

    def homepage
      homepage = @data['online_bio_url'] if found?
      homepage if homepage.present? && !homepage.include?('google.com')
    end

    def bio
      Util.fix_encoding((@data['bio'] || '') + (@data['what_i_do'] || '')) if found?
    end
    alias_method :description, :bio

    def fund_types
      return [] unless found? && @data['roles'].present?
      @fund_types ||= @data['roles'].map { |r| ROLES[r['name']] }.compact
    end
  end
end
