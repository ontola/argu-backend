# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantTree, type: :model do
  define_spec_objects
  define_model_spec_objects

  let(:constructor_args) { root.uuid }
  let(:described_instance) { described_class.new(constructor_args) }
  let(:root) { argu.edge }

  subject do
    s = described_instance
    s.cache_node(cache) if try(:cache).present?
    if described_method
      if defined?(method_args)
        if method_args.is_a?(Array)
          s.send(described_method, *method_args)
        else
          s.send(described_method, method_args)
        end
      else
        s.send(described_method)
      end
    else
      s
    end
  end

  describe '#initialize' do
    context 'with root id' do
      it { is_expected.to be_a(described_class) }
    end

    context 'with root edge' do
      let(:constructor_args) { root }
      it { is_expected.to be_a(described_class) }
    end

    context 'without root' do
      let(:constructor_args) { nil }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'with erroneous root' do
      let(:constructor_args) { '5' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#granted_group_ids' do
    context 'with public ancestor' do
      let(:method_args) { motion.edge }

      context 'without filters' do
        it { is_expected.to match_array [root.groups.custom.third.id, Group::STAFF_ID, Group::PUBLIC_ID] }
      end

      context 'with filters' do
        let(:method_args) { [motion.edge, action: :destroy, resource_type: motion.edge.owner_type] }

        it { is_expected.to match_array [Group::STAFF_ID] }
      end
    end

    context 'with private ancestor' do
      let(:method_args) { hidden_motion.edge }

      context 'without filters' do
        it { is_expected.to match_array [Group::STAFF_ID, root.groups.custom.third.id, 111, 222] }
      end
    end
  end

  describe '#trashed?' do
    let(:method_args) { edge }

    context 'with trashed self' do
      let(:edge) { trashed_motion.edge }

      it { is_expected.to eq true }
    end

    context 'without trashed self' do
      let(:edge) { motion.edge }

      it { is_expected.to eq false }
    end
  end

  describe '#tree_root' do
    context 'with edge' do
      let(:constructor_args) { root }

      it { is_expected.to eq root }
    end

    context 'with id' do
      let(:constructor_args) { root.uuid }

      it { is_expected.to eq root }
    end
  end

  describe '#tree_root_id' do
    context 'with edge' do
      let(:constructor_args) { root }

      it { is_expected.to eq root.uuid }
    end

    context 'with id' do
      let(:constructor_args) { root.uuid }

      it { is_expected.to eq root.uuid }
    end
  end

  describe '#unpublished?' do
    context 'with unpublished self' do
      let(:method_args) { unpublished_motion.edge }

      it { is_expected.to be true }
    end

    context 'with unpublished ancestor' do
      let(:method_args) { argument_unpublished_child.edge }

      it { is_expected.to be true }
    end

    context 'without unpublished  ancestor' do
      let(:method_args) { argument.edge }

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
      let(:cache) { question.edge }

      it { is_expected.to be true }
    end

    context 'without edge in cache' do
      let(:method_args) { root.id }

      it { is_expected.to be false }
    end

    context 'with wrong root' do
      let(:method_args) { root }
      let(:cache) { other_page_forum.edge }

      it { expect { subject }.to raise_error SecurityError }
    end
  end
end
