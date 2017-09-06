module NewGestionnaire
  class AvisController < ApplicationController
    layout 'new_application'

    def index
      gestionnaire_avis = current_gestionnaire.avis.includes(dossier: [:procedure, :user])
      @avis_a_donner, @avis_donnes = gestionnaire_avis.partition { |avis| avis.answer.nil? }

      @statut = params[:statut].present? ? params[:statut] : 'a-donner'

      @avis = case @statut
      when 'a-donner'
        @avis_a_donner
      when 'donnes'
        @avis_donnes
      end
    end

    def show
      @avis = avis
      @dossier = avis.dossier
    end

    def instruction
      @avis = avis
      @dossier = avis.dossier
    end

    def update
      avis.update_attributes(avis_params)
      redirect_to instruction_avis_path(avis)
    end

    private

    def avis
      current_gestionnaire.avis.includes(dossier: [:avis]).find(params[:id])
    end

    def avis_params
      params.require(:avis).permit(:answer)
    end
  end
end
