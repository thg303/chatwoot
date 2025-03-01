require 'rails_helper'

describe Integrations::Slack::SendOnSlackService do
  let(:account) { create(:account) }
  let!(:inbox) { create(:inbox, account: account) }
  let!(:contact) { create(:contact) }

  let!(:hook) { create(:integrations_hook, account: account) }
  let!(:conversation) { create(:conversation, account: account, inbox: inbox, contact: contact) }
  let!(:message) { create(:message, account: account, inbox: inbox, conversation: conversation) }

  describe '#perform' do
    it 'sent message to slack' do
      builder = described_class.new(message: message, hook: hook)
      stub_request(:post, 'https://slack.com/api/chat.postMessage')
        .to_return(status: 200, body: '', headers: {})
      slack_client = double
      expect(builder).to receive(:slack_client).and_return(slack_client)

      expect(slack_client).to receive(:chat_postMessage).with(
        channel: hook.reference_id,
        text: message.content,
        username: "Agent: #{message.sender.name}",
        thread_ts: conversation.identifier,
        icon_url: anything
      )

      builder.perform
    end
  end
end
