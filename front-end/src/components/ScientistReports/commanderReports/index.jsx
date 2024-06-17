import React, { useEffect, useState } from 'react';
import Styles from './genericReports.module.css';
import axios from 'axios';
import Cookies from "js-cookie";

const CommanderReports = () => {
    const [planets, setPlanets] = useState([]);
    const [preocupantes, setPreocupantes] = useState([]);
    const [potenciais, setNation] = useState([]);

    const faction = Cookies.get("userFaction");

    useEffect(() => {
        const planeta = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosComandantePlanetas`,);
                if (response.status === 200) {
                    const data = response.data;
                    console.log(data);
                    setPlanets(data);
                }
            } catch (error) {
                console.log(error)
            }
        }
        const preocupantes = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosplanetasPreocupantes?lider=${Cookies.get("userCPI")}`,);
                if (response.status === 200) {
                    const data = response.data;
                    setPreocupantes(data);
                }
            } catch (error) {
                console.log(error)
            }
        }
        const potenciais = async () => {
            try {
                const response = await axios.get(`http://127.0.0.1:5000/relatoriosplanetasPotenciais?nacao=${Cookies.get("userNation")}&mDist=100000`,);
                if (response.status === 200) {
                    const data = response.data;
                    setSystem(data);
                }
            } catch (error) {
                console.log(error)

            }
        }

        planeta();
        preocupantes();
        potenciais();
    }, [])

    return (
        <>
            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report infos Planetas</h3>
                    {
                        planets.map((s) => (
                            <React.Fragment key={s[0]}>

                                <h4>{s[0]}</h4>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>Planeta</p>
                                    <p className={Styles.val}>{s[1] ?? "não informado"}</p>
                                </div>
                                <div className={Styles.agrupamento}>
                                    <p className={Styles.desc}>Facção majoritária</p>
                                    <p className={Styles.val}>{s[2] ?? "não informado"}</p>
                                </div>
                            </React.Fragment>
                        ))}
                </div>
            </div>

            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report planetas preocupantes</h3>
                    {preocupantes.map((sys) => (
                        <React.Fragment key={sys[0]}>
                            <h4>{sys[0]}</h4>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>Planeta</p>
                                <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                            </div>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>Facção</p>
                                <p className={Styles.val}>{sys[2] ?? "não informado"}</p>
                            </div>
                        </React.Fragment>
                    ))}
                </div>
            </div>

            <div className={Styles.reportContainer}>
                <div className={Styles.report}>
                    <h3>Report planetas potenciais</h3>
                    {potenciais.map((sys) => (
                        <React.Fragment key={sys[0]}>
                            <h4>{sys[0]}</h4>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Comunidades</p>
                                <p className={Styles.val}>{sys[1] ?? "não informado"}</p>
                            </div>
                            <div className={Styles.agrupamento}>
                                <p className={Styles.desc}>N. Habitantes</p>
                                <p className={Styles.val}>{sys[2] ?? "não informado"}</p>
                            </div>
                        </React.Fragment>
                    ))}
                </div>
            </div>
        </>
    );
};

export default CommanderReports;
