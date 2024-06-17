import React, { useState } from 'react';
import Styles from "./getStar.module.css";
import axios from "axios";

const GetStar = () => {
    const [idEstrela, setIdEstrela] = useState("");
    const [nomeEstrela, setNomeEstrela] = useState("");
    const [starData, setStarData] = useState(null);

    const ClearFields = () => {
        setIdEstrela("");
        setNomeEstrela("");
        setStarData(null);
    };

    const handleGetStar = async () => {
        try {
            const response = await axios.get(`http://127.0.0.1:5000/estrela`, {
                params: {
                    id: idEstrela,
                    nome: nomeEstrela
                }
            });
            if (response.status === 200) {
                console.log(response.data);
                setStarData(response.data);
            } else {
                alert(response.data.error);
                setStarData(null);
            }
        } catch (error) {
            alert(`Erro: ${error.response?.data?.error || error.message}`);
            setStarData(null);
        }
    };

    return (
        <>
            <h3>Buscar Estrela</h3>
            <div className={Styles.container}>
                <input type="text" value={idEstrela} placeholder='ID da Estrela' onChange={(e) => setIdEstrela(e.target.value)} />
                <input type="text" value={nomeEstrela} placeholder='Nome da Estrela' onChange={(e) => setNomeEstrela(e.target.value)} />
                <button onClick={handleGetStar}>Buscar Estrela</button>
                {starData && (
                    <>
                        <div className={Styles.result}>
                            <h4>Dados da Estrela</h4>
                            <div className={Styles.field}>
                                <span className={Styles.fieldName}>ID:</span>
                                <span className={Styles.fieldValue}>{starData[0]}</span>
                            </div>
                            <div className={Styles.field}>
                                <span className={Styles.fieldName}>Nome:</span>
                                <span className={Styles.fieldValue}>{starData[1]}</span>
                            </div>
                            <div className={Styles.field}>
                                <span className={Styles.fieldName}>Classificação:</span>
                                <span className={Styles.fieldValue}>{starData[2]}</span>
                            </div>
                            <div className={Styles.field}>
                                <span className={Styles.fieldName}>Massa:</span>
                                <span className={Styles.fieldValue}>{starData[3]}</span>
                            </div>
                            <div className={Styles.field}>
                                <span className={Styles.fieldName}>Coordenada X:</span>
                                <span className={Styles.fieldValue}>{starData[4]}</span>
                            </div>
                            <div className={Styles.field}>
                                <span className={Styles.fieldName}>Coordenada Y:</span>
                                <span className={Styles.fieldValue}>{starData[5]}</span>
                            </div>
                            <div className={Styles.field}>
                                <span className={Styles.fieldName}>Coordenada Z:</span>
                                <span className={Styles.fieldValue}>{starData[6]}</span>
                            </div>
                        </div>
                        
                        <button onClick={ClearFields}>Limpar</button>
                    </>

                )}
            </div>

        </>
    );
};

export default GetStar;
