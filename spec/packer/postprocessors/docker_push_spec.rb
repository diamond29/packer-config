# Encoding: utf-8
# Copyright 2014 Ian Chesal
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
require 'spec_helper'

RSpec.describe Packer::PostProcessor::DockerPush do
  let(:postprocessor) do
    Packer::PostProcessor.get_postprocessor(Packer::PostProcessor::DOCKER_PUSH)
  end

  describe '#initialize' do
    it 'has a type of shell' do
      expect(postprocessor.data['type']).to eq(Packer::PostProcessor::DOCKER_PUSH)
    end
  end
end