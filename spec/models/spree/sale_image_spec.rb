require 'rails_helper'

describe Spree::SaleImage do

  let(:file) { File.new("./spec/support/image.png") }
  let(:text_file) { File.new("./spec/support/test.txt") }

  let(:sale_image) { Spree::SaleImage.new(attachment: file) }

  subject { sale_image }

  describe 'attachment' do
    it { is_expected.to have_attached_file(:attachment) }
  end

  describe 'validation' do
    it { is_expected.to validate_attachment_content_type(:attachment).allowing('image/*') }
  end

  describe 'mini_url' do
    it 'expect to receive' do
      expect(subject).to receive(:attachment).twice
      expect(subject.attachment).to receive(:url).with(:mini, false)
      subject.mini_url
    end
  end

end
