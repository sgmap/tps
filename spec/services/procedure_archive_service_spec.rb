describe ProcedureArchiveService do
  let(:procedure) { create(:procedure, :published) }
  let(:instructeur) { create(:instructeur) }
  let(:service) { ProcedureArchiveService.new(procedure) }
  let(:year) { 2020 }
  let(:month) { 3 }
  let(:date_month) { Date.strptime("#{year}-#{month}", "%Y-%m") }
  describe '#create_pending_archive' do
    context 'for a specific month' do
      it 'creates a pending archive' do
        archive = service.create_pending_archive(instructeur, 'monthly', date_month)

        expect(archive.time_span_type).to eq 'monthly'
        expect(archive.month).to eq date_month
        expect(archive.pending?).to be_truthy
      end
    end

    context 'for all months' do
      it 'creates a pending archive' do
        archive = service.create_pending_archive(instructeur, 'everything')

        expect(archive.time_span_type).to eq 'everything'
        expect(archive.month).to eq nil
        expect(archive.pending?).to be_truthy
      end
    end
  end

  describe '#collect_files_archive' do
    before do
      create_dossier_for_month(year, month)
      create_dossier_for_month(2020, month)
    end

    after { Timecop.return }

    context 'for a specific month' do
      let(:archive) { create(:archive, time_span_type: 'monthly', status: 'pending', month: date_month) }
      let(:year) { 2021 }
      let(:mailer) { double('mailer', deliver_later: true) }

      it 'collect files' do
        expect(InstructeurMailer).to receive(:send_archive).and_return(mailer)

        service.collect_files_archive(archive, instructeur)

        archive.file.open do |f|
          files = ZipTricks::FileReader.read_zip_structure(io: f)
          expect(files.size).to be 2
          expect(files.first.filename).to include("export")
          expect(files.last.filename).to include("attestation")
        end
        expect(archive.file.attached?).to be_truthy
      end
    end

    context 'for all months' do
      let(:archive) { create(:archive, time_span_type: 'everything', status: 'pending') }
      let(:mailer) { double('mailer', deliver_later: true) }

      it 'collect files' do
        expect(InstructeurMailer).to receive(:send_archive).and_return(mailer)

        service.collect_files_archive(archive, instructeur)

        archive = Archive.last
        archive.file.open do |f|
          files = ZipTricks::FileReader.read_zip_structure(io: f)
          expect(files.size).to be 4
        end
        expect(archive.file.attached?).to be_truthy
      end
    end
  end

  private

  def create_dossier_for_month(year, month)
    Timecop.freeze(Time.zone.local(year, month, 5))
    create(:dossier, :accepte, :with_attestation, procedure: procedure)
  end
end
