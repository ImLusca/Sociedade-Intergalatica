import React, { useState } from 'react';
import Styles from "./createOrbit.module.css";
import axios from "axios";

const CreateOrbit = () => {
    const [idOrbitante, setIdOrbitante] = useState("");
    const [idOrbitada, setIdOrbitada] = useState("");
    const [distMin, setDistMin] = useState("");
    const [distMax, setDistMax] = useState("");
    const [periodoOrbita, setPeriodoOrbita] = useState("");

    const ClearFields = () => {
        setIdOrbitante("");
        setIdOrbitada("");
        setDistMin("");
        setDistMax("");
        setPeriodoOrbita("");
    };

    const handleCreateOrbit = async () => {
        const jsonBody = {
            idOrbitante,
            idOrbitada,
            distMin,
            distMax,
            periodoOrbita
        };

        try {
            const response = await axios.post(`http://127.0.0.1:5000/orbita`, jsonBody);
            if (response.status === 200) {
                alert('Órbita criada com sucesso');
                ClearFields();
            } else {
                alert(response.data.error);
            }
        } catch (error) {
            alert(`Erro: ${error.response?.data?.error || error.message}`);
        }
    };

    return (
        <>
            <h3>Criar Órbita</h3>
            <div className={Styles.container}>
                <input type="text" value={idOrbitante} placeholder='ID Orbitante' onChange={(e) => setIdOrbitante(e.target.value)} />
                <input type="text" value={idOrbitada} placeholder='ID Orbitada' onChange={(e) => setIdOrbitada(e.target.value)} />
                <input type="text" value={distMin} placeholder='Distância Mínima' onChange={(e) => setDistMin(e.target.value)} />
                <input type="text" value={distMax} placeholder='Distância Máxima' onChange={(e) => setDistMax(e.target.value)} />
                <input type="text" value={periodoOrbita} placeholder='Período de Órbita' onChange={(e) => setPeriodoOrbita(e.target.value)} />
                <button onClick={handleCreateOrbit}>Criar Órbita</button>
            </div>
        </>
    );
};

export default CreateOrbit;
