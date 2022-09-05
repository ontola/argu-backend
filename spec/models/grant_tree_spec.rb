# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantTree, type: :model do
  define_spec_objects
  define_model_spec_objects

  subject do
    s = described_instance
    s.cache_node(cache) if try(:cache).present?
    if described_method
      if method_args.is_a?(Array)
        s.send(described_method, *method_args, **method_opts)
      else
        s.send(described_method, method_args, **method_opts)
      end
    else
      s
    end
  end

  let(:constructor_args) { root }
  let(:described_instance) { described_class.new(constructor_args) }
  let(:root) { argu }
  let(:method_args) { [] }
  let(:method_opts) { {} }
  let(:admin_group) { root.groups.admin.order(:created_at).first }

  describe '#initialize' do
    context 'with root id' do
      it { is_expected.to be_a(described_class) }
    end

    context 'with root edge' do
      it { is_expected.to be_a(described_class) }
    end

    context 'without root' do
      let(:constructor_args) { nil }

      it { expect { subject }.to raise_error('Edge expected as root, but got: ') }
    end

    context 'with erroneous root' do
      let(:constructor_args) { '5' }

      it { expect { subject }.to raise_error('Edge expected as root, but got: 5') }
    end
  end

  describe '#granted_group_ids' do
    context 'with public ancestor' do
      let(:method_args) { motion }

      context 'without filters' do
        it do
          expect(subject).to(
            match_array([admin_group.id, argu.users_group.id])
          )
        end
      end

      context 'with filters' do
        let(:method_args) { [motion] }
        let(:method_opts) { {action_name: :destroy, resource_type: motion.owner_type} }

        it { is_expected.to match_array [admin_group.id] }
      end
    end

    context 'with private ancestor' do
      let(:method_args) { hidden_motion }

      context 'without filters' do
        it { is_expected.to match_array [admin_group.id, 111, 222] }
      end
    end
  end

  describe '#trashed?' do
    let(:method_args) { edge }

    context 'with trashed self' do
      let(:edge) { trashed_question }

      it { is_expected.to eq true }
    end

    context 'without trashed self' do
      let(:edge) { motion }

      it { is_expected.to eq false }
    end
  end

  describe '#tree_root' do
    context 'with edge' do
      let(:constructor_args) { root }

      it { is_expected.to eq root }
    end
  end

  describe '#unpublished?' do
    context 'with unpublished self' do
      let(:method_args) { unpublished_question }

      it { is_expected.to be true }
    end

    context 'with unpublished ancestor' do
      let(:method_args) { argument_unpublished_child }

      it { is_expected.to be true }
    end

    context 'without unpublished  ancestor' do
      let(:method_args) { argument }

      it { is_expected.to be false }
    end
  end

  describe '#cached_node' do
    context 'with edge' do
      let(:method_args) { root }
      let(:cache) { root }

      it { is_expected.to be_present }
    end

    context 'with id' do
      let(:method_args) { root.id }

      it { is_expected.to be_nil }
    end
  end

  describe '#cached?' do
    context 'with edge in cache' do
      let(:method_args) { root.id }
      let(:cache) { question }

      it { is_expected.to be true }
    end

    context 'without edge in cache' do
      let(:method_args) { root.id }

      it { is_expected.to be false }
    end

    context 'with wrong root' do
      let(:method_args) { root }
      let(:cache) { other_page_forum }

      it { is_expected.to be false }
    end
  end
end
